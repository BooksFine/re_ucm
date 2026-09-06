import 'package:material_ui/material_ui.dart';

import '../tokens.dart';
import 'app_tile.dart';

class AppCounterRow extends StatelessWidget {
  const AppCounterRow({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    this.min = 1,
    this.max = 16,
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

    final stepper = Material(
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(AppRadii.sm),
            ),
            onTap: canDecrement
                ? () => onChanged((value - 1).clamp(min, max))
                : null,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Icon(
                Icons.remove_rounded,
                size: 18,
                color: canDecrement
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withValues(alpha: 0.38),
              ),
            ),
          ),
          SizedBox(
            width: 30,
            child: Center(
              child: Text(
                '$value',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          InkWell(
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(AppRadii.sm),
            ),
            onTap: canIncrement
                ? () => onChanged((value + 1).clamp(min, max))
                : null,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Icon(
                Icons.add_rounded,
                size: 18,
                color: canIncrement
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withValues(alpha: 0.38),
              ),
            ),
          ),
        ],
      ),
    );

    return AppTile(
      title: title,
      subtitle: subtitle,
      trailing: stepper,
    );
  }
}
