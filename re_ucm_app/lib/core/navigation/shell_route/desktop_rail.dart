import 'package:material_ui/material_ui.dart';

import '../nav_items.dart';

/// Desktop-rail вынесен из [NavigatorContainer] (было 3 ответственности
/// в одном файле: mobile/desktop switch, мобильная пилюля, весь rail).
class DesktopNavigationRail extends StatelessWidget {
  const DesktopNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  static const _pillWidth = 84.0;
  static const _pillMargin = 12.0;
  static const _railWidth = _pillWidth + _pillMargin * 2;
  static const _logoSize = 44.0;
  static const _logoTopInset = 6.0;
  static const _panelVerticalPadding = 16.0;
  static const _panelHorizontalPadding = 6.0;
  static const _itemGap = 12.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SizedBox(
      width: _railWidth,
      child: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: _logoTopInset),
                child: SizedBox.square(
                  dimension: _logoSize,
                  child: Image.asset('lib/assets/logo.webp'),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: _pillWidth,
                child: Material(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(28),
                  elevation: 2,
                  shadowColor: cs.shadow.withValues(alpha: 0.15),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: _panelVerticalPadding,
                      horizontal: _panelHorizontalPadding,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < navItems.length; i++) ...[
                          _DesktopRailItem(
                            item: navItems[i],
                            isSelected: selectedIndex == i,
                            onTap: () => onDestinationSelected(i),
                          ),
                          if (i < navItems.length - 1)
                            const SizedBox(height: _itemGap),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopRailItem extends StatefulWidget {
  const _DesktopRailItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_DesktopRailItem> createState() => _DesktopRailItemState();
}

class _DesktopRailItemState extends State<_DesktopRailItem> {
  static const _itemWidth = 72.0;
  static const _itemVerticalPadding = 4.0;
  static const _indicatorWidth = 56.0;
  static const _indicatorHeight = 32.0;
  static const _indicatorRadius = 16.0;
  static const _labelTopGap = 4.0;

  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final isSelected = widget.isSelected;
    final item = widget.item;

    final Color chipColor;
    if (isSelected) {
      chipColor = cs.secondaryContainer;
    } else if (_isHovered) {
      chipColor = cs.onSurface.withValues(alpha: 0.08);
    } else {
      chipColor = Colors.transparent;
    }

    final iconColor = isSelected
        ? cs.onSecondaryContainer
        : cs.onSurfaceVariant;
    final textColor = isSelected ? cs.onSurface : cs.onSurfaceVariant;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: SizedBox(
          width: _itemWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: _itemVerticalPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: _indicatorWidth,
                  height: _indicatorHeight,
                  decoration: BoxDecoration(
                    color: chipColor,
                    borderRadius: BorderRadius.circular(_indicatorRadius),
                  ),
                  child: Center(
                    child: Icon(
                      isSelected ? item.selectedIcon : item.icon,
                      color: iconColor,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: _labelTopGap),
                Text(
                  item.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: textColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
