import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

enum PredictiveBackPhase { idle, start, update, commit, cancel }

class PredictiveBackGestureBuilder extends StatefulWidget {
  const PredictiveBackGestureBuilder({
    super.key,
    this.transitionBuilder,
    required this.child,
    this.updateRouteUserGestureProgress = false,
  });

  final Widget Function(
    BuildContext context,
    PredictiveBackPhase phase,
    PredictiveBackEvent? startBackEvent,
    PredictiveBackEvent? currentBackEvent,
    Animation<double> animation,
    Widget child,
  )?
  transitionBuilder;
  final Widget child;

  final bool updateRouteUserGestureProgress;

  @override
  State<PredictiveBackGestureBuilder> createState() =>
      PredictiveBackGestureBuilderState();
}

class PredictiveBackGestureBuilderState
    extends State<PredictiveBackGestureBuilder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> animation;

  late final ModalRoute<dynamic>? route = ModalRoute.of(context);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: 1,
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (route == null) return widget.child;

    return PredictiveBackGestureObserver(
      route: route!,
      updateRouteUserGestureProgress: widget.updateRouteUserGestureProgress,
      builder: (context, phase, startBackEvent, currentBackEvent) {
        if (currentBackEvent != null) {
          _controller.value = 1 - currentBackEvent.progress;
        }

        if (widget.transitionBuilder != null) {
          return widget.transitionBuilder!(
            context,
            phase,
            startBackEvent,
            currentBackEvent,
            animation,
            widget.child,
          );
        }

        if (phase == PredictiveBackPhase.idle) {
          return widget.child;
        }

        return PredictiveBackPageSharedElementFrame(
          animation: animation,
          startBackEvent: startBackEvent,
          currentBackEvent: currentBackEvent,
          suppressionFactor: route!.animation?.value,
          child: widget.child,
        );
      },
    );
  }
}

/// Android's predictive back page shared element transition.
/// https://developer.android.com/design/ui/mobile/guides/patterns/predictive-back#shared-element-transition
class PredictiveBackPageSharedElementFrame extends StatefulWidget {
  const PredictiveBackPageSharedElementFrame({
    super.key,
    required this.animation,
    required this.startBackEvent,
    required this.currentBackEvent,
    double? suppressionFactor,
    required this.child,
  }) : suppressionFactor = suppressionFactor ?? 1.0;

  final double suppressionFactor;
  final Animation<double> animation;
  final PredictiveBackEvent? startBackEvent;
  final PredictiveBackEvent? currentBackEvent;
  final Widget child;

  @override
  State<PredictiveBackPageSharedElementFrame> createState() =>
      _PredictiveBackPageSharedElementFrameState();
}

class _PredictiveBackPageSharedElementFrameState
    extends State<PredictiveBackPageSharedElementFrame> {
  double xShift = 0;
  double yShift = 0;
  double scale = 1;

  // Constants as per the motion specs
  // https://developer.android.com/design/ui/mobile/guides/patterns/predictive-back#motion-specs
  static const double scalePercentage = 0.90;
  static const double divisionFactor = 20.0;
  static const double margin = 8.0;
  static const double borderRadius = 32.0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: _animatedBuilder,
      child: widget.child,
    );
  }

  double calcXShift() {
    final renderObject = context.findRenderObject() as RenderBox?;

    late final double width;

    if (renderObject != null) {
      width = renderObject.size.width;
    } else {
      width = MediaQuery.of(context).size.width;
    }
    final double xShift = (width / divisionFactor) - margin;

    return Tween<double>(
      begin: widget.currentBackEvent?.swipeEdge == SwipeEdge.right
          ? -xShift
          : xShift,
      end: 0.0,
    ).animate(widget.animation).value;
  }

  double calcYShift() {
    final double screenHeight = MediaQuery.of(context).size.height;

    final double startTouchY = widget.startBackEvent?.touchOffset?.dy ?? 0;
    final double currentTouchY = widget.currentBackEvent?.touchOffset?.dy ?? 0;

    // Получаем прогресс жеста (0.0 - 1.0)
    final double gestureProgress = widget.currentBackEvent?.progress ?? 0.0;

    final double yShiftMax = (screenHeight / divisionFactor) - margin;

    // Применяем прогресс жеста к максимальному сдвигу
    final double progressAdjustedYShiftMax = yShiftMax * gestureProgress;

    final double rawYShift = currentTouchY - startTouchY;
    final double easedYShift =
        Curves.easeOut.transform(
          (rawYShift.abs() / screenHeight).clamp(0.0, 1.0),
        ) *
        rawYShift.sign *
        yShiftMax;

    return easedYShift.clamp(
      -progressAdjustedYShiftMax,
      progressAdjustedYShiftMax,
    );
  }

  double calcScale() {
    return Tween<double>(
      begin: scalePercentage,
      end: 1.0,
    ).animate(widget.animation).value;
  }

  double calcBorderRadius() {
    return TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: borderRadius, end: borderRadius * 0.8),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: borderRadius * 0.8, end: 0),
        weight: 70,
      ),
    ]).animate(widget.animation).value;
  }

  Widget _animatedBuilder(BuildContext context, Widget? child) {
    final double xShift = calcXShift() * widget.suppressionFactor;
    final double yShift = calcYShift() * widget.suppressionFactor;
    double scale = 1 - (1 - calcScale()) * widget.suppressionFactor;

    return Transform.scale(
      scale: scale,
      child: Transform.translate(
        offset: Offset(xShift, yShift),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(calcBorderRadius()),
          child: child,
        ),
      ),
    );
  }
}

typedef PredictiveBackGestureObserverWidgetBuilder =
    Widget Function(
      BuildContext context,
      PredictiveBackPhase phase,
      PredictiveBackEvent? startBackEvent,
      PredictiveBackEvent? currentBackEvent,
    );

class PredictiveBackGestureObserver extends StatefulWidget {
  const PredictiveBackGestureObserver({
    super.key,
    required this.route,
    required this.builder,
    this.updateRouteUserGestureProgress = true,
  });

  final PredictiveBackGestureObserverWidgetBuilder builder;
  final ModalRoute<dynamic> route;
  final bool updateRouteUserGestureProgress;

  @override
  State<PredictiveBackGestureObserver> createState() =>
      _PredictiveBackGestureObserverState();
}

class _PredictiveBackGestureObserverState
    extends State<PredictiveBackGestureObserver>
    with WidgetsBindingObserver {
  PredictiveBackPhase get phase => _phase;
  PredictiveBackPhase _phase = PredictiveBackPhase.idle;
  set phase(PredictiveBackPhase phase) {
    if (_phase != phase && mounted) {
      setState(() => _phase = phase);
    }
  }

  /// The back event when the gesture first started.
  PredictiveBackEvent? get startBackEvent => _startBackEvent;
  PredictiveBackEvent? _startBackEvent;
  set startBackEvent(PredictiveBackEvent? startBackEvent) {
    if (_startBackEvent != startBackEvent && mounted) {
      setState(() => _startBackEvent = startBackEvent);
    }
  }

  /// The most recent back event during the gesture.
  PredictiveBackEvent? get currentBackEvent => _currentBackEvent;
  PredictiveBackEvent? _currentBackEvent;
  set currentBackEvent(PredictiveBackEvent? currentBackEvent) {
    if (_currentBackEvent != currentBackEvent && mounted) {
      setState(() => _currentBackEvent = currentBackEvent);
    }
  }

  // Begin WidgetsBindingObserver.

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    if (backEvent.isButtonEvent) return false;

    phase = PredictiveBackPhase.start;

    if (widget.updateRouteUserGestureProgress) {
      widget.route.handleStartBackGesture(progress: 1 - backEvent.progress);
    }
    startBackEvent = currentBackEvent = backEvent;
    return true;
  }

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent backEvent) {
    phase = PredictiveBackPhase.update;
    if (widget.updateRouteUserGestureProgress) {
      widget.route.handleUpdateBackGestureProgress(
        progress: 1 - backEvent.progress,
      );
    }
    currentBackEvent = backEvent;
  }

  @override
  void handleCancelBackGesture() {
    phase = PredictiveBackPhase.cancel;
    startBackEvent = currentBackEvent = null;
    if (widget.updateRouteUserGestureProgress) {
      widget.route.handleCancelBackGesture();
    }
  }

  @override
  bool handleCommitBackGesture() {
    phase = PredictiveBackPhase.commit;

    if (widget.route.popGestureInProgress) {
      widget.route.navigator?.didStopUserGesture();
    } else if (!widget.route.isCurrent) {
      phase = PredictiveBackPhase.idle;
    }

    return false;
  }

  // End WidgetsBindingObserver.

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, phase, startBackEvent, currentBackEvent);
  }
}
