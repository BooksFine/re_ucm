import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerEffect extends StatelessWidget {
  const ShimmerEffect(this.child, {super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDarkTheme ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDarkTheme
        ? Colors.grey.shade600
        : Colors.grey.shade100;

    return Shimmer.fromColors(
      period: Durations.extralong2,
      baseColor: baseColor,
      highlightColor: highlightColor,
      enabled: true,
      child: child,
    );
  }
}
