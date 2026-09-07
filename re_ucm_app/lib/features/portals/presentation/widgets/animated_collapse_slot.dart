import 'package:flutter/material.dart';

/// A lightweight wrapper widget that smoothly animates size when [isVisible] changes
/// using [AnimatedSize] without spawning redundant [AnimationController] tickers.
class AnimatedCollapseSlot extends StatelessWidget {
  const AnimatedCollapseSlot({
    super.key,
    required this.isVisible,
    required this.child,
    this.bottomPadding = 0.0,
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.easeOutCubic,
  });

  final bool isVisible;
  final Widget child;
  final double bottomPadding;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: duration,
      curve: curve,
      alignment: Alignment.topCenter,
      child: isVisible
          ? Padding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              child: child,
            )
          : const SizedBox.shrink(),
    );
  }
}
