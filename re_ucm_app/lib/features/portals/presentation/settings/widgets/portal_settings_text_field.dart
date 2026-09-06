import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../../core/ui/tokens.dart';

/// TODO: свернуть на AppTextField, когда его API позволит кнопку
/// «Применить» + спиннер в suffixIcon и заголовок сверху. Сейчас у
/// AppTextField только hint/prefix/suffix без loading-кнопки, поэтому
/// второй визуал оставлен осознанно (требует расширения core/ui,
/// которое вне владения).

class PortalSettingsTextField extends StatelessWidget {
  const PortalSettingsTextField({
    super.key,
    this.title,
    required this.controller,
    required this.hint,
    this.onSubmit,
    this.onChanged,
    this.isLoading = false,
  });

  final String? title;
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onSubmit;
  final ValueChanged<String>? onChanged;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && title!.isNotEmpty) ...[
            Text(
              title!,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.8),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    onSubmitted: onSubmit,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                if (onSubmit != null) ...[
                  const SizedBox(width: 8),
                  if (isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: M3ECircularWavyProgressIndicator(
                        size: 20,
                        strokeWidth: 2,
                      ),
                    )
                  else
                    M3EButton(
                      onPressed: () => onSubmit!(controller.text),
                      style: M3EButtonStyle.tonal,
                      size: M3EButtonSize.sm,
                      decoration: M3EButtonDecoration.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Применить'),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

