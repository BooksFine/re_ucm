import 'dart:io';
import 'dart:typed_data';

import 'package:dart_book/dart_book.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:re_ucm_core/re_ucm_core.dart' hide logger;
import 'package:re_ucm_lib/re_ucm_lib.dart';
import 'package:share_plus/share_plus.dart';

class BookSharer {
  Future<void> shareBook({
    required Uint8List bytes,
    required BookMetadata metadata,
    required SaveFormat format,
    required Portal portal,
    Book? resolvedBook,
    PathTemplate? downloadPathTemplate,
    String authorsPathSeparator = ', ',
  }) async {
    final name = _buildShareFileName(
      metadata,
      portal,
      downloadPathTemplate: downloadPathTemplate,
      authorsPathSeparator: authorsPathSeparator,
    );
    final ext = format.ext;
    final mimeType = format.mimeType;

    final tempDir = (await getTemporaryDirectory()).path;
    final filePath = p.join(tempDir, '$name$ext');
    final tempFile = File(filePath);
    await tempFile.writeAsBytes(bytes);

    final xfile = XFile(filePath, name: '$name$ext', mimeType: mimeType);

    final authors = metadata.authorsDisplay;

    final statusText = _buildStatusText(metadata, resolvedBook);

    final text =
        '${metadata.title}'
        '\nАвторы: $authors'
        '${metadata.primarySeries == null ? '' : '\nСерия: ${metadata.primarySeries!.name} #${metadata.primarySeries!.number}'}'
        '$statusText';

    await SharePlus.instance.share(
      ShareParams(files: [xfile], text: text, subject: name),
    );
  }

  /// Имя шаримого файла — через тот же [TemplateFormatter], что и
  /// сохранение на диск. Раньше здесь был упрощённый формат
  /// (серия/тайтл + свой regex) — один и тот же файл назывался
  /// по-разному в зависимости от пути отправки.
  String _buildShareFileName(
    BookMetadata data,
    Portal portal, {
    PathTemplate? downloadPathTemplate,
    required String authorsPathSeparator,
  }) {
    final template = downloadPathTemplate;
    if (template == null) {
      final fallback = data.primarySeries != null
          ? '${data.primarySeries!.name}–${data.primarySeries!.number}'
          : data.title;
      return fallback.replaceAll(TemplateFormatter.illegalChars, '');
    }
    return TemplateFormatter.buildTemplateFileName(
      data,
      portal,
      downloadPathTemplate: template,
      authorsPathSeparator: authorsPathSeparator,
    );
  }

  String _buildStatusText(BookMetadata data, Book? resolvedBook) {
    if (data.isFinished) {
      return '\n\nПолностью';
    }
    final sections =
        resolvedBook?.content.blocks.whereType<BookSection>().toList() ??
        const [];
    final lastChapter = sections.length > 1
        ? sections[sections.length - 2]
        : (sections.isNotEmpty ? sections.first : null);
    final lastTitle = lastChapter != null
        ? bookInlinesToPlainText(lastChapter.title).trim()
        : '';
    return lastTitle.isNotEmpty ? '\n\nПо: «$lastTitle»' : '';
  }
}
