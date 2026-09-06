import 'package:dart_book/dart_book.dart';
import 'package:re_ucm_core/re_ucm_core.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

/// Презентационный билдер текста шаринга.
/// Раньше русские строки («Авторы:», «Серия:», «Полностью», «По: ...»)
/// и `bookInlinesToPlainText` жили в domain [BookSharer] — UI-текст
/// не должен жить в domain. Sharer принимает готовые `fileName`/`text`.
class BookShareTextBuilder {
  const BookShareTextBuilder._();

  /// Имя файла — всегда через [TemplateFormatter], без fallback-ветки.
  /// Раньше при `downloadPathTemplate == null` имя строилось из
  /// серии/тайтла со своим regex — один файл назывался по-разному.
  static String buildFileName(
    BookMetadata metadata,
    Portal portal, {
    required PathTemplate downloadPathTemplate,
    required String authorsPathSeparator,
  }) {
    return TemplateFormatter.buildTemplateFileName(
      metadata,
      portal,
      downloadPathTemplate: downloadPathTemplate,
      authorsPathSeparator: authorsPathSeparator,
    );
  }

  static String buildText(BookMetadata metadata, Book? resolvedBook) {
    final authors = metadata.authorsDisplay;
    final statusText = _buildStatusText(metadata, resolvedBook);
    return '${metadata.title}'
        '\nАвторы: $authors'
        '${metadata.primarySeries == null ? '' : '\nСерия: ${metadata.primarySeries!.name} #${metadata.primarySeries!.number}'}'
        '$statusText';
  }

  static String _buildStatusText(BookMetadata data, Book? resolvedBook) {
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
