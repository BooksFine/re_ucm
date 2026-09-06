import 'package:material_ui/material_ui.dart';

import '../../../../core/ui/tokens.dart';

InputDecoration settingsInputDecoration(
  BuildContext context, {
  String? labelText,
  String? errorText,
  Widget? suffixIcon,
  bool isEditing = false,
  EdgeInsetsGeometry contentPadding = const EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 12,
  ),
}) {
  final theme = Theme.of(context);
  final outlineColor = theme.colorScheme.outlineVariant.withValues(alpha: 0.8);

  return InputDecoration(
    isDense: true,
    labelText: labelText,
    labelStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurfaceVariant,
    ),
    floatingLabelBehavior: FloatingLabelBehavior.always,
    errorText: errorText,
    contentPadding: contentPadding,
    filled: true,
    fillColor: theme.colorScheme.surfaceContainerLow,
    suffixIcon: suffixIcon,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      borderSide: BorderSide(color: outlineColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      borderSide: BorderSide(
        color: isEditing ? theme.colorScheme.onSurfaceVariant : outlineColor,
        width: isEditing ? 1.5 : 1.0,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      borderSide: BorderSide(
        color: theme.colorScheme.onSurfaceVariant,
        width: 2,
      ),
    ),
  );
}
