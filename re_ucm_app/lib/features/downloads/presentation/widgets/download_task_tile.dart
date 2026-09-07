import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/re_ucm_core.dart' hide logger;

import '../../../../core/ui/tokens.dart';
import '../../../common/widgets/book_cover_image.dart';
import '../../domain/download_task.cg.dart';
import '../../domain/downloads_service.cg.dart';
import '../models/download_status_viewmodel.dart';

enum DownloadTileTrailingType {
  chevron,
  cancel,
  none,
}

/// Единый генератор ключа для тайлов загрузки.
ValueKey<String> downloadTileKey(DownloadTask task) => ValueKey<String>(
      DownloadsServiceBase.taskKey(task.session.portal.code, task.bookId),
    );

/// Унифицированный тайл задачи скачивания (используется на главной и в модале).
class DownloadTaskTile extends StatelessWidget {
  const DownloadTaskTile({
    super.key,
    required this.task,
    this.onTap,
    this.trailingType = DownloadTileTrailingType.chevron,
    this.trailing,
  });

  final DownloadTask task;
  final VoidCallback? onTap;
  final DownloadTileTrailingType trailingType;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final vm = task.viewModel;
        final meta = task.metadata;
        final coverUrl = meta?.cover?.ref.id;
        final authors = meta?.authorsDisplay ?? task.session.portal.name;

        final theme = Theme.of(context);
        final cs = theme.colorScheme;
        final isActive = task.isActive;
        final isCompleted = task.isCompleted;
        final isFailed = task.isFailed;
        final isCancelled = task.status == DownloadTaskStatus.cancelled;
        final tot = task.progress.total ?? 0;

        final cardColor = isActive
            ? cs.primaryContainer.withValues(alpha: AppOpacity.soft)
            : cs.surfaceContainerHigh.withValues(alpha: 0.45);

        final borderColor = isActive
            ? cs.primary.withValues(alpha: AppOpacity.soft)
            : Colors.transparent;

        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          elevation: 0,
          color: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            side: BorderSide(color: borderColor, width: AppBorderWidth.regular),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BookCoverImage(
                    coverUrl: (coverUrl?.isNotEmpty == true) ? coverUrl : null,
                    width: 44,
                    height: 60,
                    iconSize: 22,
                    errorIcon: Icons.downloading_rounded,
                    placeholderIcon: Icons.downloading_rounded,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          vm.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          authors,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (isActive) ...[
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  vm.statusText,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: cs.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (tot > 0 && vm.progress != null) ...[
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  '${(vm.progress! * 100).toInt()}%',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: cs.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          M3ELinearWavyProgressIndicator(
                            value: vm.progress,
                            height: 6,
                            strokeWidth: 3,
                            color: cs.primary,
                            backgroundColor: cs.primary.withValues(
                              alpha: AppOpacity.wash,
                            ),
                          ),
                        ] else if (isCompleted) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 15,
                                color: cs.primary,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                task.savedFilePath != null
                                    ? 'Сохранено'
                                    : 'Готово к сохранению',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ] else if (isFailed || isCancelled) ...[
                          Row(
                            children: [
                              Icon(
                                isFailed
                                    ? Icons.error_rounded
                                    : Icons.cancel_outlined,
                                size: 15,
                                color: isFailed ? cs.error : cs.onSurfaceVariant,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                isFailed ? 'Ошибка загрузки' : 'Отменено',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isFailed ? cs.error : cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _buildTrailing(context, cs),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrailing(BuildContext context, ColorScheme cs) {
    if (trailing != null) return trailing!;

    return switch (trailingType) {
      DownloadTileTrailingType.chevron => Icon(
          Icons.chevron_right_rounded,
          size: 22,
          color: cs.onSurfaceVariant.withValues(alpha: AppOpacity.muted),
        ),
      DownloadTileTrailingType.cancel => IconButton(
          tooltip: 'Отменить загрузку',
          icon: Icon(Icons.close_rounded, size: 20, color: cs.error),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          onPressed: () {
            HapticFeedback.lightImpact();
            task.cancel();
          },
        ),
      DownloadTileTrailingType.none => const SizedBox.shrink(),
    };
  }
}
