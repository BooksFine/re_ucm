import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:dart_book/dart_book.dart';
import 'package:re_ucm_core/models/progress.dart';

import '../settings/domain/save_format.dart';

class ResolvedBookResult {
  final Book book;
  final List<ImageDownloadTask> failedTasks;

  const ResolvedBookResult({required this.book, required this.failedTasks});
}

class BookExporter {
  static Future<ResolvedBookResult> resolveBook({
    required BookMetadata metadata,
    required BookContent content,
    required BookResourceResolver resourceResolver,
    List<BookResource> initialResources = const [],
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
      resources: initialResources,
    );

    var lastStates = <BookResourceDownloadState>[];

    final resolvedBook = await initialBook.resolveResources(
      resourceResolver,
      baseUri: metadata.source,
      maxConcurrent: maxConcurrentDownloads,
      onProgress: (completed, total, states) {
        lastStates = states;
        onProgress?.call(
          Progress(
            stage: Stages.imageDownloading,
            current: completed,
            total: total,
            activeTasks: List.unmodifiable(states.map(_taskFromState)),
          ),
        );
      },
    );

    final failedTasks = lastStates
        .where((s) => s.isFailed)
        .map(_taskFromState)
        .toList(growable: false);

    return ResolvedBookResult(book: resolvedBook, failedTasks: failedTasks);
  }

  static Future<Uint8List> encode({
    required Book book,
    required SaveFormat format,
    BookEncodingOptions? options,
    void Function(Progress progress)? onProgress,
  }) async {
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

    final params = _IsolateEncodeParams(encoder, book, options);
    final Uint8List bytes = await Isolate.run(params.run);

    onProgress?.call(Progress(stage: Stages.done));

    return bytes;
  }

  static ImageDownloadTask _taskFromState(BookResourceDownloadState s) {
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
