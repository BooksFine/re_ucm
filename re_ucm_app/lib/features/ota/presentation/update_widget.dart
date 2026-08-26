import 'package:flutter/material.dart';

import '../../../core/constants.dart';
import '../../../core/di.dart';
import '../../../core/ui/constants.dart';
import '../../common/widgets/btn.dart';
import '../../common/widgets/outlined_btn.dart';
import 'update_controller.dart';

class UpdateWidget extends StatefulWidget {
  const UpdateWidget({super.key});

  @override
  State<UpdateWidget> createState() => _UpdateWidgetState();
}

class _UpdateWidgetState extends State<UpdateWidget> {
  late final UpdateController controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller = UpdateController(AppDependencies.of(context).otaService);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBusy = controller.isDownloading ||
        controller.state == UpdateState.installing;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: appPadding * 3,
          vertical: appPadding * 2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: appPadding * 2),
            Text(
              'Доступно обновление',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: appPadding),
            Text(
              '$appVersion => ${controller.actualVersion ?? "—"}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: appPadding * 3),
            if (controller.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(appPadding),
                margin: const EdgeInsets.only(bottom: appPadding * 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(cardBorderRadius),
                ),
                child: Text(
                  controller.errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.colorScheme.onErrorContainer,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
            AnimatedCrossFade(
              duration: Durations.medium3,
              firstCurve: Curves.easeInOut,
              secondCurve: Curves.easeInOut,
              sizeCurve: Curves.easeInOut,
              crossFadeState: isBusy
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton1(
                    func: () =>
                        controller.downloadAndInstall(() => setState(() {})),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.download_rounded, size: 20),
                        SizedBox(width: 8),
                        Text('Скачать и установить'),
                      ],
                    ),
                  ),
                  const SizedBox(height: appPadding * 1.5),
                  OutlinedButton1(
                    text: 'Открыть в браузере',
                    func: () => controller.openInBrowser(),
                  ),
                ],
              ),
              secondChild: Container(
                padding: const EdgeInsets.all(appPadding * 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(cardBorderRadius),
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 0.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          controller.state == UpdateState.installing
                              ? 'Запуск установщика...'
                              : 'Скачивание обновления...',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${(controller.progress * 100).toInt()}%',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: appPadding),
                    TweenAnimationBuilder<double>(
                      duration: Durations.short4,
                      curve: Curves.easeInOut,
                      tween: Tween<double>(
                        begin: 0,
                        end: controller.progress,
                      ),
                      builder: (context, value, _) {
                        return LinearProgressIndicator(
                          borderRadius: BorderRadius.circular(90),
                          value: controller.state == UpdateState.installing
                              ? null
                              : value,
                          minHeight: 4,
                        );
                      },
                    ),
                    if (controller.isDownloading) ...[
                      const SizedBox(height: appPadding),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () =>
                              controller.cancelDownload(() => setState(() {})),
                          child: const Text('Отмена'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: appPadding * 2),
          ],
        ),
      ),
    );
  }
}
