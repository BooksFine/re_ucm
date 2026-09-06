import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/constants.dart';
import '../../../core/di.dart';
import '../../../core/ui/tokens.dart';
import '../../../core/ui/widgets/app_progress_card.dart';
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

  double? get _progressValue {
    if (controller.totalBytes > 0) {
      return (controller.recievedBytes / controller.totalBytes).clamp(0.0, 1.0);
    }
    return null;
  }

  static String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBusy =
        controller.isDownloading || controller.state == UpdateState.installing;
    final hasDirectDownload =
        controller.service.getPlatformDownloadUrl() != null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Text('Доступно обновление', style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '$appVersion => ${controller.actualVersion ?? "—"}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            if (controller.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: AppRadii.smRadius,
                ),
                child: Text(
                  controller.errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
            ElevatedButton1(
              isLoading: isBusy,
              func: () {
                if (hasDirectDownload) {
                  controller.downloadAndInstall(() => setState(() {}));
                } else {
                  controller.openInBrowser();
                }
              },
              child: Text(
                hasDirectDownload
                    ? 'Скачать и установить'
                    : 'Открыть в браузере',
              ),
            ),
            AnimatedSize(
              duration: Durations.medium2,
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: isBusy
                  ? Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppProgressCard(
                            title: controller.state == UpdateState.installing
                                ? 'Запуск установщика'
                                : 'Загрузка обновления',
                            statusText: controller.totalBytes > 0
                                ? '${_formatBytes(controller.recievedBytes)} / ${_formatBytes(controller.totalBytes)}${_progressValue != null ? ' (${(_progressValue! * 100).toInt()}%)' : ''}'
                                : (controller.state == UpdateState.installing
                                    ? 'Установка...'
                                    : 'Подготовка...'),
                            progress: _progressValue,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Align(
                            alignment: Alignment.centerRight,
                            child: M3EButton(
                              style: M3EButtonStyle.tonal,
                              size: M3EButtonSize.sm,
                              onPressed: () => controller.cancelDownload(
                                () => setState(() {}),
                              ),
                              child: const Text('Отмена'),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            if (hasDirectDownload && !isBusy) ...[
              const SizedBox(height: AppSpacing.md),
              OutlinedButton1(
                text: 'Открыть в браузере',
                func: () => controller.openInBrowser(),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
