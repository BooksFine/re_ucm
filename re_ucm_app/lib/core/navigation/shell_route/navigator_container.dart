import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'animated_branch_container.dart';
import 'nav_bar.dart';

class NavigatorContainer extends StatelessWidget {
  const NavigatorContainer({
    super.key,
    required this.navigationShell,
    required this.children,
  });

  final StatefulNavigationShell navigationShell;
  final List<Widget> children;

  static const _wideBreakpoint = 600.0;
  static const _mobileBarHorizontalInset = 16.0;
  static const _mobileBarBottomInset = 16.0;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            _DesktopNavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onDestinationSelected,
            ),
            Expanded(
              child: AnimatedBranchContainer(
                currentIndex: navigationShell.currentIndex,
                axis: Axis.vertical,
                children: children,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          AnimatedBranchContainer(
            currentIndex: navigationShell.currentIndex,
            children: children,
          ),
          Positioned(
            left: _mobileBarHorizontalInset,
            right: _mobileBarHorizontalInset,
            bottom:
                MediaQuery.paddingOf(context).bottom + _mobileBarBottomInset,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: NavBar(
                currentIndex: navigationShell.currentIndex,
                onDestinationSelected: _onDestinationSelected,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopNavigationRail extends StatelessWidget {
  const _DesktopNavigationRail({
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

  static const _items = [
    (
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Главная',
    ),
    (
      icon: Icons.explore_outlined,
      selectedIcon: Icons.explore_rounded,
      label: 'Источники',
    ),
    (
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
      label: 'Настройки',
    ),
  ];

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
                        for (var i = 0; i < _items.length; i++) ...[
                          _DesktopRailItem(
                            item: _items[i],
                            isSelected: selectedIndex == i,
                            onTap: () => onDestinationSelected(i),
                          ),
                          if (i < _items.length - 1)
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

  final ({IconData icon, IconData selectedIcon, String label}) item;
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
