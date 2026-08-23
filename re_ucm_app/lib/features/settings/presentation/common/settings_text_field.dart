import 'package:flutter/material.dart';

import '../../../../core/ui/constants.dart';

class SettingsTextField extends StatelessWidget {
  const SettingsTextField({
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

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: appPadding * 2,
        vertical: appPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && title!.isNotEmpty) ...[
            Text(
              title!,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: appPadding / 2),
          ],
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: onChanged,
                  controller: controller,
                  onSubmitted: onSubmit,
                  decoration: InputDecoration(
                    visualDensity: VisualDensity.standard,
                    hintText: hint,
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.6,
                      ),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: appPadding * 1.5,
                      vertical: appPadding * 1.2,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(cardBorderRadius),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              if (onSubmit != null) ...[
                const SizedBox(width: appPadding),
                AnimatedSwitcher(
                  duration: Durations.medium2,
                  child: isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(appPadding * 1.2),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : Material(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(
                            cardBorderRadius,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              cardBorderRadius,
                            ),
                            onTap: () => onSubmit!(controller.text),
                            child: Padding(
                              padding: const EdgeInsets.all(appPadding * 1.2),
                              child: Icon(
                                Icons.check,
                                size: 20,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
