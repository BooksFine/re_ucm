import 'package:material_ui/material_ui.dart';

import '../../../../core/ui/tokens.dart';

/// Оформление полей настроек.
///
/// Базовые параметры (isDense, filled, fillColor, border, focusedBorder,
/// contentPadding) наследуются из [ThemeData.inputDecorationTheme] (см. theme.dart).
InputDecoration settingsInputDecoration(
  BuildContext context, {
  String? labelText,
  String? errorText,
  Widget? suffixIcon,
  bool isEditing = false,
  EdgeInsetsGeometry? contentPadding,
}) {
  final theme = Theme.of(context);

  return InputDecoration(
    labelText: labelText,
    labelStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurfaceVariant,
    ),
    floatingLabelBehavior: FloatingLabelBehavior.always,
    errorText: errorText,
    contentPadding: contentPadding,
    suffixIcon: suffixIcon,
    enabledBorder: isEditing
        ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            borderSide: BorderSide(
              color: theme.colorScheme.onSurfaceVariant,
              width: 1.5,
            ),
          )
        : null,
  );
}
