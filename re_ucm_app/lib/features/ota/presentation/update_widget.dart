import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/constants.dart';
import '../../../core/di.dart';
import '../../../core/ui/formatters.dart';
import '../../../core/ui/tokens.dart';
import '../../../core/ui/widgets/app_card.dart';
import '../../../core/ui/widgets/app_progress_card.dart';
import '../../common/widgets/app_button.dart';
import 'update_controller.dart';

class UpdateWidget extends StatefulWidget {
  const UpdateWidget({super.key});

  @override
  State<UpdateWidget> createState() => _UpdateWidgetState();
}

class _UpdateWidgetState extends State<UpdateWidget> {
  UpdateController? _controller;
  bool? _hasDirectDownload;

  UpdateController get controller => _controller!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null) {
      _controller = UpdateController(AppDependencies.of(context).otaService);
      // Мемоизация: сканирование assets не должно выполняться на каждый
      // Observer-ребилд прогресса (десятки раз в секунду).
      _hasDirectDownload =
          _controller!.service.getPlatformDownloadUrl() != null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDirectDownload = _hasDirectDownload ?? false;

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
            Text(
              'Доступно обновление',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '$appVersion => ${controller.actualVersion ?? "—"}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Observer(
              builder: (_) {
                final errorMessage = controller.errorMessage;
                if (errorMessage == null) {
                  return const SizedBox.shrink();
                }
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: AppRadii.smRadius,
                  ),
                  child: Text(
                    errorMessage,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                );
              },
            ),
            Observer(
              builder: (_) {
                final isBusy = controller.isDownloading ||
                    controller.state == UpdateState.installing;
                return AppButton(
                  isLoading: isBusy,
                  onPressed: () {
                    if (hasDirectDownload) {
                      controller.downloadAndInstall();
                    } else {
                      controller.openInBrowser();
                    }
                  },
                  child: Text(
                    hasDirectDownload
                        ? 'Скачать и установить'
                        : 'Открыть в браузере',
                  ),
                );
              },
            ),
            AnimatedSize(
              duration: Durations.medium2,
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: Observer(
                builder: (_) {
                  final isBusy = controller.isDownloading ||
                      controller.state == UpdateState.installing;
                  if (!isBusy) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Observer(
                          builder: (_) => AppProgressCard(
                            titleWidget: AppCardTitle.text(
                              controller.state == UpdateState.installing
                                  ? 'Запуск установщика'
                                  : 'Загрузка обновления',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            statusWidget: Text(
                              controller.counterText(formatBytes) ??
                                  (controller.state ==
                                          UpdateState.installing
                                      ? 'Установка...'
                                      : 'Подготовка...'),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            progress: controller.totalBytes > 0
                                ? controller.progress
                                : null,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Align(
                          alignment: Alignment.centerRight,
                          child: AppButton(
                            style: M3EButtonStyle.tonal,
                            size: M3EButtonSize.sm,
                            onPressed: () =>
                                controller.cancelDownload(),
                            child: const Text('Отмена'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (hasDirectDownload)
              Observer(
                builder: (_) {
                  final isBusy = controller.isDownloading ||
                      controller.state == UpdateState.installing;
                  if (isBusy) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: AppButton(
                      style: M3EButtonStyle.outlined,
                      onPressed: () => controller.openInBrowser(),
                      child: const Text('Открыть в браузере'),
                    ),
                  );
                },
              ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
