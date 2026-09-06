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
          _StepButton(
            icon: Icons.remove_rounded,
            enabled: canDecrement,
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(AppRadii.sm),
            ),
            onTap: () => onChanged((value - 1).clamp(min, max)),
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
          _StepButton(
            icon: Icons.add_rounded,
            enabled: canIncrement,
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(AppRadii.sm),
            ),
            onTap: () => onChanged((value + 1).clamp(min, max)),
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

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.borderRadius,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final BorderRadius borderRadius;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: borderRadius,
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Icon(
          icon,
          size: 18,
          color: enabled
              ? cs.onSurface
              : cs.onSurface.withValues(alpha: 0.38),
        ),
      ),
    );
  }
}
