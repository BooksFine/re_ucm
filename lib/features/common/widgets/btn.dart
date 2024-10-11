import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../core/constants.dart';

class ElevatedButton1 extends StatelessWidget {
  const ElevatedButton1({
    super.key,
    required this.child,
    required this.func,
    this.isLoading = false,
    this.height,
  });
  final Widget child;
  final double? height;
  final void Function()? func;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(cardBorderRadius),
      color: func != null
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).disabledColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(cardBorderRadius),
        onTap: isLoading ? null : func,
        child: SizedBox(
          height: height ?? 48,
          width: double.infinity,
          child: Center(
            child: isLoading
                ? LoadingAnimationWidget.progressiveDots(
                    color: Colors.white,
                    size: 60,
                  )
                : DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: child,
                  ),
          ),
        ),
      ),
    );
  }
}
