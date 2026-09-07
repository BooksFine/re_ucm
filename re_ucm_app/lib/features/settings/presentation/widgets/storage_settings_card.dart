import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/di.dart';
import '../../../../core/ui/tokens.dart';
import '../../../../core/ui/widgets/widgets.dart';
import '../settings_controller.cg.dart';

class StorageSettingsCard extends StatelessWidget {
  const StorageSettingsCard({super.key, this.controller});

  final SettingsController? controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveController =
        controller ?? AppDependencies.of(context).settingsController;

    return AppCard(
      icon: Icons.folder_copy_rounded,
      titleWidget: AppCardTitle.text('Сохранение'),
      subtitleWidget: const AppCardSubtitle(
        text: 'Параметры сохранения файлов',
      ),
      children: [
        Observer(
          builder: (_) => AppCheckboxRow(
            title: 'Всегда спрашивать, куда сохранять',
            subtitle: 'Запрашивать папку перед каждым скачиванием',
            value: effectiveController.saveDirectory == null ||
                effectiveController.saveDirectory!.isEmpty,
            enabled: !effectiveController.isPickingDirectory,
            onChanged: effectiveController.setAlwaysAskDirectory,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Observer(
          builder: (_) {
            final saveDir = effectiveController.saveDirectory;
            final hasDir = saveDir != null && saveDir.isNotEmpty;

            return AnimatedSize(
              duration: AppDurations.expand,
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: hasDir
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppSectionHeader('Основная папка'),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(AppRadii.lg),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant
                                  .withValues(alpha: AppOpacity.strong),
                              width: AppBorderWidth.regular,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.folder_rounded,
                                color: theme.colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Tooltip(
                                  message: saveDir,
                                  waitDuration: const Duration(
                                    milliseconds: 500,
                                  ),
                                  child: Text(
                                    saveDir,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              M3EButton(
                                onPressed: effectiveController.isPickingDirectory
                                    ? null
                                    : effectiveController.pickSaveDirectory,
                                style: M3EButtonStyle.tonal,
                                size: M3EButtonSize.sm,
                                decoration: M3EButtonDecoration.styleFrom(
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('Изменить'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        AppCheckboxRow(
                          title: 'Сохранять автоматически',
                          subtitle:
                              'Сохранять файл сразу после завершения загрузки',
                          value: effectiveController.autoSaveOnComplete,
                          onChanged: effectiveController.updateAutoSaveOnComplete,
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            );
          },
        ),
      ],
    );
  }
}
