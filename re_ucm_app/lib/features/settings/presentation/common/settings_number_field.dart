import 'package:flutter/material.dart';

import '../../../../core/ui/constants.dart';

class SettingsNumberField extends StatelessWidget {
  const SettingsNumberField({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    this.min = 1,
    this.max = 20,
    required this.onChanged,
  });

  final String title;
  final String? subtitle;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canDecrement = value > min;
    final canIncrement = value < max;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: appPadding * 2,
        vertical: appPadding,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: appPadding),
          Material(
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(cardBorderRadius),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(cardBorderRadius),
                  ),
                  onTap: canDecrement
                      ? () => onChanged((value - 1).clamp(min, max))
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.all(appPadding * 1.2),
                    child: Icon(
                      Icons.remove,
                      size: 20,
                      color: canDecrement
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: appPadding * 1.5),
                  child: Text(
                    '$value',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(cardBorderRadius),
                  ),
                  onTap: canIncrement
                      ? () => onChanged((value + 1).clamp(min, max))
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.all(appPadding * 1.2),
                    child: Icon(
                      Icons.add,
                      size: 20,
                      color: canIncrement
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
