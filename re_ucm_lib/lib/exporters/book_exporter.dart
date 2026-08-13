import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:dart_book/dart_book.dart';
import 'package:re_ucm_core/models/progress.dart';

import '../settings/domain/save_format.dart';

class BookExporter {
  static Future<Uint8List> export({
    required BookMetadata metadata,
    required BookContent content,
    required SaveFormat format,
    required BookResourceResolver resourceResolver,
    BookEncodingOptions? options,
    bool includeAfterword = true,
    int maxConcurrentDownloads = 4,
    void Function(Progress progress)? onProgress,
  }) async {
    onProgress?.call(Progress(stage: .analyzing));

    final blocks = List<BookBlock>.from(content.blocks);

    if (includeAfterword) {
      blocks.add(_createBooksFineAfterword(metadata.source, metadata.title));
    }

    final fullContent = BookContent(
      blocks: blocks,
      footnotes: content.footnotes,
    );

    final initialBook = Book(
      metadata: metadata,
      content: fullContent,
      resources: const [],
    );

    final resolvedBook = await initialBook.resolveResources(
      resourceResolver,
      baseUri: metadata.source,
      maxConcurrent: maxConcurrentDownloads,
      onProgress: (completed, total, states) {
        final activeTasks = states.map((s) {
          final ImageDownloadStatus status;
          if (s.isCompleted) {
            status = ImageDownloadStatus.completed;
          } else if (s.isFailed) {
            status = ImageDownloadStatus.failed;
          } else if (s.receivedBytes > 0) {
            status = ImageDownloadStatus.downloading;
          } else {
            status = ImageDownloadStatus.pending;
          }

          final cleanName = s.id.split('/').last.split('?').first;
          return ImageDownloadTask(
            id: cleanName.isNotEmpty ? cleanName : s.id,
            receivedBytes: s.receivedBytes,
            totalBytes: s.totalBytes,
            status: status,
          );
        }).toList();

        onProgress?.call(
          Progress(
            stage: Stages.imageDownloading,
            current: completed,
            total: total,
            activeTasks: List.unmodifiable(activeTasks),
          ),
        );
      },
    );

    onProgress?.call(Progress(stage: .building));

    final BookEncoder encoder;
    switch (format) {
      case .fb2:
        encoder = Fb2Encoder();
      case .fb2Zip:
        encoder = Fb2ZipEncoder();
      case .epub:
        encoder = EpubEncoder();
    }

    final params = _IsolateEncodeParams(encoder, resolvedBook, options);
    final Uint8List bytes = await Isolate.run(params.run);

    onProgress?.call(Progress(stage: Stages.done));

    return bytes;
  }

  static BookSection _createBooksFineAfterword(Uri? bookUrl, String bookTitle) {
    final blocks = <BookBlock>[
      const BookEmptyLine(),
      BookParagraph(
        inlines: [
          const BookText(
            'Эту книгу вы прочли бесплатно благодаря Telegram каналу ',
          ),
          BookLink(
            href: Uri.parse('https://t.me/BookFine'),
            children: const [BookText('@books_fine')],
          ),
        ],
      ),
      const BookEmptyLine(),
      const BookParagraph(
        inlines: [
          BookText('У нас вы найдете другие книги (или продолжение этой).'),
        ],
      ),
      BookParagraph(
        inlines: [
          const BookText('Еще есть активный чат: '),
          BookLink(
            href: Uri.parse('https://t.me/books_fine_com'),
            children: const [BookText('@books_fine_com')],
          ),
        ],
      ),
      const BookEmptyLine(),
      const BookParagraph(
        inlines: [
          BookText(
            'Если вам понравилось, поддержите автора наградой, или активностью.',
          ),
        ],
      ),
    ];

    if (bookUrl != null) {
      blocks.addAll([
        BookParagraph(
          inlines: [
            const BookStrong(children: [BookText('Страница книги: ')]),
            BookLink(href: bookUrl, children: [BookText(bookTitle)]),
          ],
        ),
        const BookEmptyLine(),
      ]);
    }

    return BookSection(
      title: const [BookText('Послесловие @books_fine')],
      blocks: blocks,
    );
  }
}

class _IsolateEncodeParams {
  final BookEncoder encoder;
  final Book book;
  final BookEncodingOptions? options;

  _IsolateEncodeParams(this.encoder, this.book, this.options);

  FutureOr<Uint8List> run() {
    return encoder.encode(book, options: options);
  }
}
