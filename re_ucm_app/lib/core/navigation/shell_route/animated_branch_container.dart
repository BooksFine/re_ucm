import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:motor/motor.dart';

class AnimatedBranchContainer extends StatefulWidget {
  /// Creates an AnimatedBranchContainer with smooth spring transitions.
  const AnimatedBranchContainer({
    super.key,
    required this.currentIndex,
    required this.children,
    this.motion = M3EMotion.standardSpatialDefault,
    this.axis = Axis.horizontal,
  });

  /// The index (in [children]) of the branch Navigator to display.
  final int currentIndex;

  /// The children (branch Navigators) to display in this container.
  final List<Widget> children;

  /// Motion physics definition.
  final M3EMotion motion;

  /// Axis along which the branch transition moves.
  final Axis axis;

  @override
  State<AnimatedBranchContainer> createState() =>
      _AnimatedBranchContainerState();
}

class _AnimatedBranchContainerState extends State<AnimatedBranchContainer>
    with TickerProviderStateMixin {
  final List<SingleMotionController> _controllers = [];
  int _targetIndex = 0;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _targetIndex = widget.currentIndex;
    _previousIndex = widget.currentIndex;
    _initControllers();
  }

  void _initControllers() {
    for (var i = 0; i < widget.children.length; i++) {
      final controller = SingleMotionController(
        motion: widget.motion.toMotion(),
        vsync: this,
        initialValue: i == widget.currentIndex ? 1.0 : 0.0,
      );
      _controllers.add(controller);
    }
  }

  void _syncControllers() {
    while (_controllers.length < widget.children.length) {
      final i = _controllers.length;
      final controller = SingleMotionController(
        motion: widget.motion.toMotion(),
        vsync: this,
        initialValue: i == widget.currentIndex ? 1.0 : 0.0,
      );
      _controllers.add(controller);
    }
    while (_controllers.length > widget.children.length) {
      final c = _controllers.removeLast();
      c.dispose();
    }
  }

  @override
  void didUpdateWidget(AnimatedBranchContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.children.length != oldWidget.children.length) {
      _syncControllers();
    }

    if (widget.motion != oldWidget.motion) {
      for (final controller in _controllers) {
        controller.motion = widget.motion.toMotion();
      }
    }

    if (widget.currentIndex != oldWidget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
      _targetIndex = widget.currentIndex;

      if (_previousIndex < _controllers.length) {
        _controllers[_previousIndex].animateTo(0.0);
      }
      if (_targetIndex < _controllers.length) {
        _controllers[_targetIndex].animateTo(1.0);
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          _branchNavigatorWrapper(
            i,
            AnimatedBuilder(
              animation: _controllers[i],
              builder: (context, child) {
                final value = _controllers[i].value;
                final bool isOffstage =
                    value <= 0.001 && i != widget.currentIndex;

                final bool isForward = _targetIndex >= _previousIndex;
                final double direction = isForward ? 1.0 : -1.0;

                // Subtle organic shift: 24dp for gentle natural movement
                final double offsetSign = (i == _targetIndex)
                    ? direction
                    : -direction;
                final double offset = 24.0 * (1.0 - value) * offsetSign;
                final double opacity = value.clamp(0.0, 1.0);
                final Offset translation = widget.axis == Axis.horizontal
                    ? Offset(offset, 0)
                    : Offset(0, offset);

                return Offstage(
                  offstage: isOffstage,
                  child: RepaintBoundary(
                    child: Transform.translate(
                      offset: translation,
                      child: Opacity(opacity: opacity, child: child),
                    ),
                  ),
                );
              },
              child: widget.children[i],
            ),
          ),
      ],
    );
  }

  Widget _branchNavigatorWrapper(int index, Widget navigator) => IgnorePointer(
    ignoring: index != widget.currentIndex,
    child: TickerMode(enabled: index == widget.currentIndex, child: navigator),
  );
}
