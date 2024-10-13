import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:re_ucm_core/models/progress.dart';

import '../../../../core/constants.dart';
import '../book_page_controller.cg.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.controller});

  final BookPageController controller;

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return AnimatedSize(
        duration: Durations.short4,
        child: switch (controller.progress.stage) {
          Stages.imageDownloading => Container(
              margin: const EdgeInsets.symmetric(vertical: appPadding * 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(cardBorderRadius),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 0.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(appPadding * 2),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Загрузка изображений: '),
                        Text(
                          '${controller.progress.current}'
                          ' из ${controller.progress.total}',
                        ),
                      ],
                    ),
                    const SizedBox(height: appPadding),
                    TweenAnimationBuilder(
                      duration: Durations.short4,
                      curve: Curves.easeInOut,
                      tween: Tween<double>(
                        begin: 0,
                        end: controller.progress.current! /
                            controller.progress.total!,
                      ),
                      builder: (context, value, _) {
                        return LinearProgressIndicator(
                          borderRadius: BorderRadius.circular(90),
                          value: value,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          Stages.error => Text(controller.progress.message!),
          _ => const SizedBox(height: appPadding * 2),
        },
      );
    });
  }
}
