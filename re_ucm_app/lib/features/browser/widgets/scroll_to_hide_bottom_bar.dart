import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Виджет-контейнер, инкапсулирующий попиксельное скрытие/появление
/// нижней плавающей панели (пилюли) при вертикальном скролле.
class ScrollToHideBottomBar extends StatefulWidget {
  const ScrollToHideBottomBar({
    super.key,
    required this.child,
    required this.bottomBar,
    required this.bottomBarHeight,
    required this.bottomPadding,
    this.bottomOffset = 16.0,
  });

  final Widget child;
  final Widget bottomBar;
  final double bottomBarHeight;
  final double bottomPadding;
  final double bottomOffset;

  @override
  State<ScrollToHideBottomBar> createState() => _ScrollToHideBottomBarState();
}

class _ScrollToHideBottomBarState extends State<ScrollToHideBottomBar>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<double> _translate = ValueNotifier<double>(0.0);
  double _accumulatedDeltaY = 0.0;
  double _lastDirection = 0.0;
  int _lastPointerMoveTime = 0;
  bool _isScrollGestureActive = false;
  static const double _touchSlop = 16.0;

  late final AnimationController _animController;
  Animation<double>? _offsetAnimation;

  double get _maxBottomOffset => widget.bottomBarHeight + 24.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..addListener(() {
        if (_offsetAnimation != null) {
          _translate.value = _offsetAnimation!.value;
        }
      });
  }

  @override
  void dispose() {
    _animController.dispose();
    _translate.dispose();
    super.dispose();
  }

  void _animateTo(double target) {
    if ((_translate.value - target).abs() < 1.0) {
      _translate.value = target;
      return;
    }
    _animController.stop();
    _offsetAnimation = Tween<double>(
      begin: _translate.value,
      end: target,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward(from: 0.0);
  }

  void _snap() {
    final maxOffset = _maxBottomOffset;
    if (maxOffset <= 0) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final isFling = (now - _lastPointerMoveTime) < 80;

    double target;
    if (isFling && _lastDirection > 3.0) {
      target = 0.0;
    } else if (isFling && _lastDirection < -3.0) {
      target = maxOffset;
    } else {
      final progress = _translate.value / maxOffset;
      if (progress > 0.6) {
        target = maxOffset;
      } else if (progress < 0.4) {
        target = 0.0;
      } else {
        target = _lastDirection <= 0 ? maxOffset : 0.0;
      }
    }
    _animateTo(target);
  }

  void _onPointerDown(PointerDownEvent event) {
    _animController.stop();
    _accumulatedDeltaY = 0.0;
    _lastDirection = 0.0;
    _isScrollGestureActive = false;
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (event.synthesized) return;
    final dy = event.delta.dy;
    if (dy == 0) return;

    _lastPointerMoveTime = DateTime.now().millisecondsSinceEpoch;

    if (!_isScrollGestureActive) {
      _accumulatedDeltaY += dy;
      if (_accumulatedDeltaY.abs() >= _touchSlop) {
        _isScrollGestureActive = true;
      } else {
        return;
      }
    }

    _lastDirection = dy;
    final newTranslate = (_translate.value - dy).clamp(0.0, _maxBottomOffset);
    if (newTranslate != _translate.value) {
      _translate.value = newTranslate;
    }
  }

  void _onPointerUp() {
    if (_isScrollGestureActive) {
      _isScrollGestureActive = false;
      _snap();
    }
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      _animController.stop();
      final dy = -event.scrollDelta.dy;
      _lastDirection = dy;
      final newTranslate =
          (_translate.value - dy * 0.5).clamp(0.0, _maxBottomOffset);
      _translate.value = newTranslate;
      _snap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        Positioned.fill(
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: _onPointerDown,
            onPointerMove: _onPointerMove,
            onPointerUp: (_) => _onPointerUp(),
            onPointerCancel: (_) {
              _isScrollGestureActive = false;
            },
            onPointerSignal: _onPointerSignal,
          ),
        ),
        ValueListenableBuilder<double>(
          valueListenable: _translate,
          builder: (_, translate, _) => Positioned(
            bottom: widget.bottomOffset + widget.bottomPadding - translate,
            left: 0,
            right: 0,
            child: Center(child: widget.bottomBar),
          ),
        ),
      ],
    );
  }
}
