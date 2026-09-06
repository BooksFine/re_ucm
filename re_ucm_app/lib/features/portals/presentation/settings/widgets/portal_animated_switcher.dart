import 'package:material_ui/material_ui.dart';

class PortalAnimatedSwitcher extends StatelessWidget {
  const PortalAnimatedSwitcher({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Durations.long1,
      reverseDuration: Durations.medium2,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      layoutBuilder: (child, previousChildren) => Stack(
        alignment: Alignment.topCenter,
        children: [
          ...previousChildren.map(
            (child) => Positioned.fill(
              child: OverflowBox(
                alignment: Alignment.topCenter,
                maxHeight: double.infinity,
                child: IgnorePointer(child: child),
              ),
            ),
          ),
          ?child,
        ],
      ),
      child: child,
    );
  }
}
