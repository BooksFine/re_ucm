import 'package:material_ui/material_ui.dart';

import '../../../core/ui/tokens.dart';

class RecentBookContainer extends StatelessWidget {
  const RecentBookContainer({
    super.key,
    required this.isDownloading,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin = const EdgeInsets.symmetric(vertical: 4),
  });

  final bool isDownloading;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(
          color: isDownloading
              ? cs.primary.withValues(alpha: 0.4)
              : cs.outlineVariant.withValues(alpha: 0.35),
          width: isDownloading ? 1.2 : 0.6,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
