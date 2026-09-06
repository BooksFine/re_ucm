import 'package:flutter/material.dart';

/// A wrapper widget that smoothly animates size and opacity when [isVisible] changes.
/// Used for smooth list additions, removals, and section reveals without abrupt layout snaps.
class AnimatedCollapseSlot extends StatefulWidget {
  const AnimatedCollapseSlot({
    super.key,
    required this.isVisible,
    required this.child,
    this.bottomPadding = 0.0,
    this.duration = const Duration(milliseconds: 280),
  });

  final bool isVisible;
  final Widget child;
  final double bottomPadding;
  final Duration duration;

  @override
  State<AnimatedCollapseSlot> createState() => _AnimatedCollapseSlotState();
}

class _AnimatedCollapseSlotState extends State<AnimatedCollapseSlot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.isVisible ? 1.0 : 0.0,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedCollapseSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        if (_animation.isDismissed) {
          return const SizedBox.shrink();
        }
        return SizeTransition(
          sizeFactor: _animation,
          alignment: AlignmentDirectional.topStart,
          child: FadeTransition(
            opacity: _animation,
            child: child,
          ),
        );
      },
      child: IgnorePointer(
        ignoring: !widget.isVisible,
        child: SizedBox(
          width: double.infinity,
          child: widget.bottomPadding > 0
              ? Padding(
                  padding: EdgeInsets.only(bottom: widget.bottomPadding),
                  child: widget.child,
                )
              : widget.child,
        ),
      ),
    );
  }
}
