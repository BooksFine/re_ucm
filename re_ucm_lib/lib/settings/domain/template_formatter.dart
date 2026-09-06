import 'package:dart_book/dart_book.dart';
import 'package:re_ucm_core/models/portal.dart';

import 'path_placeholders.dart';
import 'path_template.cg.dart';

class TemplateFormatter {
  // Инвертированные скобки "панцирь черепахи" для максимальной уникальности
  // ⦘ (U+2998 Right Tortoise Shell Bracket)
  static const String startTagChar = '\u2998';
  // ⦗ (U+2997 Left Tortoise Shell Bracket)
  static const String endTagChar = '\u2997';

  /// Единый набор запрещённых в именах файлов символов.
  /// Раньше UI-валидация ([path_template_field]) использовала свой
  /// RegExp без `/\` — domain молча заменял их, и превью врало.
  static final RegExp illegalChars = RegExp(r'[<>:"/\\|?*]');

  // Регулярка: ищем всё между ⦘ и ⦗
  static final RegExp tagRegExp = RegExp(
    '$startTagChar([^$endTagChar]+)$endTagChar',
  );

  static String buildTemplateFileName(
    BookMetadata data,
    Portal portal, {
    required PathTemplate downloadPathTemplate,
    required String authorsPathSeparator,
  }) {
    var template = data.primarySeries != null
        ? downloadPathTemplate.seriesPath.trim()
        : downloadPathTemplate.path.trim();

    if (template.isEmpty) {
      template = data.primarySeries != null
          ? PathTemplate.initialSeriesPathPlaceholder
          : PathTemplate.initialPathPlaceholder;
    }
    final rendered = renderTemplate(
      template,
      data,
      portal,
      authorsPathSeparator: authorsPathSeparator,
    ).trim();

    return rendered;
  }

  static String renderTemplate(
    String template,
    BookMetadata data,
    Portal portal, {
    required String authorsPathSeparator,
  }) {
    final separator = authorsPathSeparator.trim();
    final effectiveSeparator = separator.isEmpty ? ', ' : separator;

    return template.replaceAllMapped(tagRegExp, (match) {
      final label = match.group(1) ?? '';
      final placeholder = PathPlaceholders.fromLabel(label);
      if (placeholder == null) return '';
      final value = placeholder.resolve(data, portal, effectiveSeparator);
      return value.replaceAll(illegalChars, '_');
    });
  }
}
