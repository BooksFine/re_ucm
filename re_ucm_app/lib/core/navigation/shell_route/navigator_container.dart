import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../ui/tokens.dart';
import 'animated_branch_container.dart';
import 'desktop_rail.dart';
import 'nav_bar.dart';

class NavigatorContainer extends StatelessWidget {
  const NavigatorContainer({
    super.key,
    required this.navigationShell,
    required this.children,
  });

  final StatefulNavigationShell navigationShell;
  final List<Widget> children;

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
    final isWide =
        MediaQuery.sizeOf(context).width >= AppBreakpoints.mobileNav;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            DesktopNavigationRail(
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

