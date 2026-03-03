import 'package:flutter/material.dart';

class SettingsAnimatedSwitcher extends StatelessWidget {
  const SettingsAnimatedSwitcher({super.key, required this.child});

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
        alignment: .topCenter,
        children: [
          ...previousChildren.map(
            (child) => Positioned.fill(
              child: OverflowBox(
                alignment: .topCenter,
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
