import 'package:material_ui/material_ui.dart';

import '../tokens.dart';

/// Единый визуал текстовых полей: поиск в источниках + ссылка на главной.
/// Логика остается в вызывающем коде, здесь только decoration.
///
/// Визуал (бордеры, радиус, fill, contentPadding) полностью берётся из
/// [ThemeData.inputDecorationTheme] (см. theme.dart) — инлайн
/// [OutlineInputBorder]'ов здесь нет, чтобы не разъезжаться с темой.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    required this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String hint;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      validator: validator,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: cs.onSurface,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: cs.onSurfaceVariant.withValues(alpha: AppOpacity.emphasized),
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
