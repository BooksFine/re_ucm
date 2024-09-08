import 'dart:math';

import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/navigation/router_delegate.dart';
import 'settings.dart';

Future openSettingsDialog(BuildContext context) {
  return Nav.pushDialog((_, __, ___) => const SettingsDialog());
}

final _settingsKey = GlobalKey();

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.all(appPadding * 2),
          child: Hero(
            tag: 'Settings',
            flightShuttleBuilder: (flightContext, animation, flightDirection,
                fromHeroContext, toHeroContext) {
              return SettingsFlightShuttle(
                animation: animation,
                toHeroWidget: toHeroContext.widget,
                fromHeroWidget: fromHeroContext.widget,
              );
            },
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(cardBorderRadius * 2),
                color: Theme.of(context).colorScheme.surface,
              ),
              clipBehavior: Clip.antiAlias,
              child: Settings(
                key: _settingsKey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsFlightShuttle extends StatelessWidget {
  const SettingsFlightShuttle({
    super.key,
    required this.animation,
    required this.toHeroWidget,
    required this.fromHeroWidget,
  });

  final Animation<double> animation;
  final Widget fromHeroWidget;
  final Widget toHeroWidget;

  @override
  Widget build(BuildContext context) {
    final Widget settings = animation.status == AnimationStatus.reverse
        ? fromHeroWidget
        : toHeroWidget;

    final double settingsWidth =
        min(MediaQuery.sizeOf(context).width - appPadding * 4, 500);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final double opacity =
            animation.value <= 0.5 ? 0 : (animation.value - 0.5) * 2;

        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              cardBorderRadius * 2 + (1 - animation.value) * cardBorderRadius,
            ),
            color: Color.lerp(
              Theme.of(context).colorScheme.secondaryContainer,
              Theme.of(context).colorScheme.surface,
              animation.value,
            ),
          ),
          child: Stack(
            children: [
              Opacity(
                opacity: max(0, 1 - animation.value * 2),
                child: Center(
                  child: Center(
                    child: Icon(
                      Icons.settings,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ),
              Opacity(
                opacity: opacity,
                child: OverflowBox(
                  // alignment: Alignment.centerRight,
                  maxWidth: settingsWidth,
                  child: Center(child: settings),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
