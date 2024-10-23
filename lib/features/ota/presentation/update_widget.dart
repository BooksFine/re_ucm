import 'package:flutter/material.dart';
import 'package:re_ucm_core/ui/constants.dart';

import '../../../core/constants.dart';
import 'update_controller.dart';

class UpdateWidget extends StatefulWidget {
  const UpdateWidget({
    super.key,
  });

  @override
  State<UpdateWidget> createState() => _UpdateWidgetState();
}

class _UpdateWidgetState extends State<UpdateWidget> {
  final UpdateController controller = UpdateController();

  @override
  Widget build(BuildContext context) {
    return Center(
      heightFactor: 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: appPadding * 4),
          Text(
            'Доступно обновление',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: appPadding * 2),
          Text(
            '$appVersion => ${controller.actualVersion}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: appPadding),
          Card(
            margin: const EdgeInsets.all(appPadding * 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(cardBorderRadius),
            ),
            color: Theme.of(context).colorScheme.primary,
            child: InkWell(
              borderRadius: BorderRadius.circular(cardBorderRadius),
              onTap: controller.progressStream == null
                  ? () => controller.updateApp(() => setState(() {}))
                  : null,
              child: AnimatedSize(
                duration: Durations.short4,
                child: Container(
                  padding: const EdgeInsets.all(appPadding),
                  width: double.infinity,
                  child: controller.progressStream == null
                      ? Text(
                          'Установить',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            fontSize: 16,
                          ),
                        )
                      : StreamBuilder(
                          stream: controller.progressStream,
                          builder: (_, progress) {
                            return TweenAnimationBuilder(
                              duration: Durations.short4,
                              curve: Curves.easeInOut,
                              tween: Tween<double>(
                                begin: 0,
                                end: progress.data ?? 0,
                              ),
                              builder: (context, value, _) {
                                return LinearProgressIndicator(
                                  borderRadius: BorderRadius.circular(90),
                                  value: value / 100,
                                  color: Colors.white,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .surface
                                      .withValues(alpha: 0.5),
                                );
                              },
                            );
                          },
                        ),
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.paddingOf(context).bottom),
        ],
      ),
    );
  }
}
