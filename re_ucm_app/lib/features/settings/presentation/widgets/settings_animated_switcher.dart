import 'package:flutter/material.dart';

class SettingsAnimatedSwitcher extends StatelessWidget {
  const SettingsAnimatedSwitcher({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Durations.medium2,
      layoutBuilder: (child, previousChildren) => Stack(
        alignment: .topCenter,
        children: [
          ?child,
          ...previousChildren.map(
            (child) => Positioned.fill(
              child: OverflowBox(
                alignment: .topCenter,
                maxHeight: double.infinity,
                child: IgnorePointer(child: child),
              ),
            ),
          ),
        ],
      ),
      child: child,
    );
  }
}
