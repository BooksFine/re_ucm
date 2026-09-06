import 'package:material_ui/material_ui.dart';

class CoverFallback extends StatelessWidget {
  final double width;
  final double height;
  final double? iconSize;
  final IconData icon;

  const CoverFallback({
    super.key,
    required this.width,
    required this.height,
    this.iconSize,
    this.icon = Icons.book_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        icon,
        size: iconSize ?? 24,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
