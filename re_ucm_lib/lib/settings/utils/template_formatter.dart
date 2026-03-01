import 'package:re_ucm_core/models/book.dart';

import '../domain/path_placeholders.dart';
import '../domain/path_template.cg.dart';
import '../settings_service.dart';

class TemplateFormatter {
  // Инвертированные скобки "панцирь черепахи" для максимальной уникальности
  // ⦘ (U+2998 Right Tortoise Shell Bracket)
  static const String startTagChar = '\u2998';
  // ⦗ (U+2997 Left Tortoise Shell Bracket)
  static const String endTagChar = '\u2997';

  // Регулярка: ищем всё между ⦘ и ⦗
  static final RegExp tagRegExp = RegExp(
    '$startTagChar([^$endTagChar]+)$endTagChar',
  );

  static String buildTemplateFileName(Book data, SettingsService settings) {
    var template = settings.downloadPathTemplate.path.trim();

    if (template.isEmpty) template = PathTemplate.initialPathPlaceholder;
    final rendered = renderTemplate(template, data, settings).trim();

    return rendered;
  }

  static String renderTemplate(
      String template, Book data, SettingsService settings) {
    final separator = settings.authorsPathSeparator;
    final authorsSeparator = separator.isEmpty ? ', ' : separator;

    return template.replaceAllMapped(tagRegExp, (match) {
      final label = match.group(1) ?? '';
      final placeholder = PathPlaceholders.fromLabel(label);
      if (placeholder == null) return '';
      final value = placeholder.resolve(data, authorsSeparator);
      return value.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    });
  }
}
