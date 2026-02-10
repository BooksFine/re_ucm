import 'package:flutter/material.dart';

const double _defaultScrollControlDisabledMaxHeightRatio = 9.0 / 16.0;

class ModalBottomSheetPage extends Page {
  final Widget child;
  final Color? backgroundColor;
  final String? barrierLabel;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip? clipBehavior;
  final BoxConstraints? constraints;
  final Color? barrierColor;
  final bool isScrollControlled;
  final double scrollControlDisabledMaxHeightRatio;
  final bool isDismissible;
  final bool enableDrag;
  final bool? showDragHandle;
  final bool useSafeArea;
  final AnimationController? transitionAnimationController;
  final Offset? anchorPoint;
  final AnimationStyle? sheetAnimationStyle;

  const ModalBottomSheetPage({
    required this.child,
    this.backgroundColor,
    this.barrierLabel,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.constraints,
    this.barrierColor,
    this.isScrollControlled = false,
    this.scrollControlDisabledMaxHeightRatio =
        _defaultScrollControlDisabledMaxHeightRatio,
    this.isDismissible = true,
    this.enableDrag = true,
    this.showDragHandle,
    this.useSafeArea = false,
    this.transitionAnimationController,
    this.anchorPoint,
    this.sheetAnimationStyle,
  });

  @override
  Route createRoute(BuildContext context) {
    return ModalBottomSheetRoute(
      builder: (_) => child,
      backgroundColor: backgroundColor,
      barrierLabel: barrierLabel,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      constraints: constraints,
      modalBarrierColor: barrierColor,
      isScrollControlled: isScrollControlled,
      scrollControlDisabledMaxHeightRatio: scrollControlDisabledMaxHeightRatio,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      showDragHandle: showDragHandle,
      useSafeArea: useSafeArea,
      transitionAnimationController: transitionAnimationController,
      anchorPoint: anchorPoint,
      sheetAnimationStyle: sheetAnimationStyle,
      settings: this,
    );
  }
}
