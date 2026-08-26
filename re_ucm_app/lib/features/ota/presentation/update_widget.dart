import 'package:flutter/material.dart';

import '../../../core/constants.dart';
import '../../../core/di.dart';
import '../../../core/ui/constants.dart';
import '../../book/presentation/widgets/progress/progress_card.dart';
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
            AnimatedSize(
              duration: Durations.medium2,
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: isBusy
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ProgressCard<void>(
                          title: controller.state == UpdateState.installing
                              ? 'Запуск установщика:'
                              : 'Загрузка обновления:',
                          current: (controller.progress * 100).toInt(),
                          total: 100,
                          items: const [],
                          itemBuilder: (_, _) => const SizedBox.shrink(),
                        ),
                        if (controller.isDownloading)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => controller
                                  .cancelDownload(() => setState(() {})),
                              child: const Text('Отмена'),
                            ),
                          ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton1(
                          func: () => controller
                              .downloadAndInstall(() => setState(() {})),
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
            ),
            const SizedBox(height: appPadding * 2),
          ],
        ),
      ),
    );
  }
}
