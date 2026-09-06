import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/re_ucm_core.dart' hide logger;

import '../../../../core/ui/tokens.dart';
import '../../../common/widgets/book_cover_image.dart';
import '../../domain/download_task.cg.dart';
import '../../domain/downloads_service.cg.dart';

/// Единый тайл задачи для live-карточки (compact) и списка загрузок.
/// Раньше `_SingleActiveTaskCard` и `_TaskListItem` дублировали
/// обложку/заголовок/прогресс с разными формулами — теперь одна
/// формула через [DownloadTask.viewModel].
class DownloadListTile extends StatelessWidget {
  const DownloadListTile({
    super.key,
    required this.task,
    this.onTap,
    this.compact = false,
  });

  final DownloadTask task;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final vm = task.viewModel;
        final meta = task.metadata;
        final coverUrl = meta?.cover?.ref.id;
        final authors = meta?.authorsDisplay ?? task.session.portal.name;

        if (compact) {
          return _CompactBody(
            task: task,
            title: vm.title,
            authors: authors,
            statusText: vm.statusText,
            progress: vm.progress,
            coverUrl: coverUrl,
            onTap: onTap,
          );
        }
        return _FullBody(
          task: task,
          title: vm.title,
          statusText: vm.statusText,
          progress: vm.progress,
          coverUrl: coverUrl,
          onTap: onTap,
        );
      },
    );
  }
}

class _CompactBody extends StatelessWidget {
  const _CompactBody({
    required this.task,
    required this.title,
    required this.authors,
    required this.statusText,
    required this.progress,
    required this.coverUrl,
    required this.onTap,
  });

  final DownloadTask task;
  final String title;
  final String authors;
  final String statusText;
  final double? progress;
  final String? coverUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(
          color: cs.primary.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.card),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    BookCoverImage(
                      coverUrl: coverUrl,
                      width: 38,
                      height: 52,
                      iconSize: 20,
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
                            title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
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
                          const SizedBox(height: 2),
                          Text(
                            statusText,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    IconButton(
                      tooltip: 'Отменить загрузку',
                      icon: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: cs.error,
                      ),
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        task.cancel();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                M3ELinearWavyProgressIndicator(
                  value: progress,
                  height: 6,
                  strokeWidth: 3,
                  color: cs.primary,
                  backgroundColor: cs.primary.withValues(alpha: 0.15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FullBody extends StatelessWidget {
  const _FullBody({
    required this.task,
    required this.title,
    required this.statusText,
    required this.progress,
    required this.coverUrl,
    required this.onTap,
  });

  final DownloadTask task;
  final String title;
  final String statusText;
  final double? progress;
  final String? coverUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = task.isCompleted;
    final isActive = task.isActive;
    final isFailed = task.isFailed;
    final tot = task.progress.total ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              BookCoverImage(
                coverUrl: (coverUrl?.isNotEmpty == true) ? coverUrl : null,
                width: 44,
                height: 60,
                iconSize: 22,
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (isActive) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              statusText,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (tot > 0 && progress != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              '${(progress! * 100).toInt()}%',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 5),
                      M3ELinearWavyProgressIndicator(
                        value: progress,
                        height: 6,
                        strokeWidth: 3,
                        backgroundColor: theme.colorScheme.primary.withValues(
                          alpha: 0.15,
                        ),
                      ),
                    ] else if (isCompleted) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 15,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            task.savedFilePath != null
                                ? 'Сохранено'
                                : 'Готово к сохранению',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ] else if (isFailed) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.error_rounded,
                            size: 15,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Ошибка загрузки',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ключ тайла — через единый [DownloadsServiceBase.taskKey].
ValueKey<String> downloadTileKey(DownloadTask task) =>
    ValueKey<String>(DownloadsServiceBase.taskKey(task.session.portal.code, task.bookId));
