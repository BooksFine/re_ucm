import 'dart:ui';

import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:motor/motor.dart';

class NavBar extends StatelessWidget {
  const NavBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  static const List<_NavBarItem> _navItems = [
    _NavBarItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Главная',
    ),
    _NavBarItem(
      icon: Icons.explore_outlined,
      selectedIcon: Icons.explore_rounded,
      label: 'Источники',
    ),
    _NavBarItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
      label: 'Настройки',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final toolbarDecoration = M3EFloatingToolbarDecoration(
      motion: M3EMotion.expressiveSpatialFast,
      colors: M3EFloatingToolbarColors(
        toolbarContainerColor: cs.surfaceContainer,
        toolbarContentColor: cs.onSurface,
        fabContainerColor: cs.primaryContainer,
        fabContentColor: cs.onPrimaryContainer,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      expandedShadowElevation: 2.0,
    );

    return M3EHorizontalFloatingToolbar(
      expanded: true,
      decoration: toolbarDecoration,
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_navItems.length, (index) {
          return _M3ENavBarTab(
            key: ValueKey(_navItems[index].label),
            item: _navItems[index],
            isSelected: index == currentIndex,
            onTap: () => onDestinationSelected(index),
          );
        }),
      ),
    );
  }
}

class _NavBarItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavBarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class _M3ENavBarTab extends StatefulWidget {
  final _NavBarItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _M3ENavBarTab({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_M3ENavBarTab> createState() => _M3ENavBarTabState();
}

class _M3ENavBarTabState extends State<_M3ENavBarTab>
    with SingleTickerProviderStateMixin {
  late final SingleMotionController _controller;
  double _expandedWidth = 128.0;

  @override
  void initState() {
    super.initState();
    _controller = SingleMotionController(
      motion: M3EMotion.expressiveSpatialFast.toMotion(),
      vsync: this,
      initialValue: widget.isSelected ? 1.0 : 0.0,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _expandedWidth = _measureExpandedWidth();
  }

  double _measureExpandedWidth() {
    final theme = Theme.of(context);
    final style = (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
      fontWeight: FontWeight.w600,
    );
    final tp = TextPainter(
      text: TextSpan(text: widget.item.label, style: style),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    // icon(24) + gap(6) + text + padding(12 left + 12 right)
    return (24.0 + 6.0 + tp.width + 24.0).ceilToDouble();
  }

  @override
  void didUpdateWidget(covariant _M3ENavBarTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      _controller.animateTo(widget.isSelected ? 1.0 : 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        final clampedProgress = progress.clamp(0.0, 1.0);
        final double width = lerpDouble(48.0, _expandedWidth, progress)!;

        final Color bgColor = widget.isSelected
            ? cs.secondaryContainer
            : Colors.transparent;
        final Color contentColor = widget.isSelected
            ? cs.onSecondaryContainer
            : cs.onSurfaceVariant;

        return Container(
          width: width,
          height: 48.0,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: widget.onTap,
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed)) {
                  return contentColor.withValues(alpha: 0.12);
                }
                if (states.contains(WidgetState.hovered)) {
                  return contentColor.withValues(alpha: 0.08);
                }
                return null;
              }),
              child: ClipRect(
                child: Center(
                  child: OverflowBox(
                    minWidth: 0,
                    maxWidth: _expandedWidth + 20,
                    minHeight: 0,
                    maxHeight: 48,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.isSelected
                              ? widget.item.selectedIcon
                              : widget.item.icon,
                          color: contentColor,
                          size: 24,
                        ),
                        if (progress > 0.01)
                          ClipRect(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              widthFactor: clampedProgress,
                              child: Opacity(
                                opacity: clampedProgress,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: Text(
                                    widget.item.label,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: contentColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.clip,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
