import 'package:material_ui/material_ui.dart';

import '../../../core/ui/app_colors_extension.dart';

/// Вид снека [AppSnack.show].
enum AppSnackKind {
  /// Нейтральное сообщение, стандартные цвета SnackBarTheme.
  info,

  /// Успех: фон [AppColorsExtension.success], текст [AppColorsExtension.onSuccess].
  success,

  /// Ошибка: фон [ColorScheme.errorContainer], текст [ColorScheme.onErrorContainer].
  error,
}

/// Единая точка показа снеков поверх [ScaffoldMessenger].
///
/// База — [SnackBarTheme] из theme.dart (floating behavior,
/// форма, dismissDirection). Цвет задаётся только через [kind].
abstract final class AppSnack {
  static void show(
    BuildContext context,
    String message, {
    AppSnackKind kind = AppSnackKind.info,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 4),
    EdgeInsetsGeometry? margin,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final appColors = context.appColors;
    final (Color? backgroundColor, Color? foregroundColor) = switch (kind) {
      AppSnackKind.info => (null, null),
      AppSnackKind.success => (appColors.success, appColors.onSuccess),
      AppSnackKind.error => (cs.errorContainer, cs.onErrorContainer),
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: foregroundColor != null
                ? TextStyle(color: foregroundColor)
                : null,
          ),
          backgroundColor: backgroundColor,
          action: action,
          duration: duration,
          margin: margin,
        ),
      );
  }
}
