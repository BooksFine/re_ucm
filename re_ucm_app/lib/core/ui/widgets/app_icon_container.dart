import 'package:material_ui/material_ui.dart';

import '../tokens.dart';

class AppIconContainer extends StatelessWidget {
  const AppIconContainer({
    super.key,
    required this.icon,
    this.size = 40,
    this.iconSize = 20,
    this.color,
    this.backgroundColor,
    this.borderRadius,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final Color? color;
  final Color? backgroundColor;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadii.md),
      ),
      child: Center(
        child: Icon(
          icon,
          color: color ?? theme.colorScheme.onSurfaceVariant,
          size: iconSize,
        ),
      ),
    );
  }
}
