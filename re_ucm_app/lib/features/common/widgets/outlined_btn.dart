import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../core/ui/constants.dart';

class OutlinedButton1 extends StatelessWidget {
  const OutlinedButton1({
    super.key,
    required this.text,
    required this.func,
    this.isLoading = false,
    this.height,
  });
  final String text;
  final double? height;
  final bool isLoading;
  final void Function()? func;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: func != null
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).disabledColor,
        ),
        borderRadius: BorderRadius.circular(cardBorderRadius),
      ),
      height: height ?? 48,
      width: double.infinity,
      child: InkWell(
        borderRadius: BorderRadius.circular(cardBorderRadius),
        onTap: isLoading ? null : func,
        child: Center(
          child: isLoading
              ? LoadingAnimationWidget.progressiveDots(
                  color: Theme.of(context).colorScheme.primary,
                  size: 60,
                )
              : Text(
                  text,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: func != null
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).disabledColor,
                  ),
                ),
        ),
      ),
    );
  }
}
