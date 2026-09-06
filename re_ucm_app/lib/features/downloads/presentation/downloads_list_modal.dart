import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/models/progress.dart';

import '../../../core/di.dart';
import '../../../core/ui/tokens.dart';
import '../domain/download_task.cg.dart';
import 'download_modal.dart';

Future<void> showDownloadsListModal(BuildContext context) async {
  final isWide = MediaQuery.sizeOf(context).width >= 600;

  if (isWide) {
    await showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.dialog),
        ),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 620),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                child: DownloadsListContent(
                  isWide: true,
                  onClose: () => Navigator.of(dialogCtx).pop(),
                ),
              ),
              Positioned(
                top: 14,
                right: 14,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  tooltip: 'Закрыть',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  } else {
    await showM3EModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      builder: (sheetCtx) {
        final screenHeight = MediaQuery.sizeOf(sheetCtx).height;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              0,
              16,
              MediaQuery.viewInsetsOf(sheetCtx).bottom + 16,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: screenHeight * 0.75),
              child: DownloadsListContent(
                isWide: false,
                onClose: () => Navigator.of(sheetCtx).pop(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class DownloadsListContent extends StatelessWidget {
  const DownloadsListContent({
    super.key,
    required this.isWide,
    required this.onClose,
  });

  final bool isWide;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final downloadsService = AppDependencies.of(context).downloadsService;

    return Observer(
      builder: (context) {
        final activeTasks = downloadsService.activeTasks;
        final completedTasks = downloadsService.completedTasks;
        final allTasks = downloadsService.allTasks;

        if (allTasks.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.download_done_rounded,
                    size: 52,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Нет активных загрузок',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Row
            Row(
              children: [
                Text(
                  'Загрузки',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${allTasks.length}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (completedTasks.isNotEmpty)
                  M3EButton.icon(
                    style: M3EButtonStyle.text,
                    size: M3EButtonSize.sm,
                    onPressed: downloadsService.clearCompletedTasks,
                    icon: const Icon(Icons.clear_all_rounded, size: 18),
                    label: const Text('Очистить'),
                  ),
                if (isWide) const SizedBox(width: 28),
              ],
            ),
            const SizedBox(height: 16),

            // Tasks List
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [
                  if (activeTasks.isNotEmpty) ...[
                    _SectionTitle(title: 'АКТИВНЫЕ (${activeTasks.length})'),
                    const SizedBox(height: 8),
                    for (final task in activeTasks)
                      _TaskListItem(
                        task: task,
                        onTap: () {
                          onClose();
                          showDownloadModalForTask(context, task);
                        },
                      ),
                  ],
                  if (activeTasks.isNotEmpty && completedTasks.isNotEmpty)
                    const SizedBox(height: 16),
                  if (completedTasks.isNotEmpty) ...[
                    _SectionTitle(
                      title: 'ЗАВЕРШЁННЫЕ (${completedTasks.length})',
                    ),
                    const SizedBox(height: 8),
                    for (final task in completedTasks)
                      _TaskListItem(
                        task: task,
                        onTap: () {
                          onClose();
                          showDownloadModalForTask(context, task);
                        },
                      ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _TaskListItem extends StatelessWidget {
  const _TaskListItem({required this.task, required this.onTap});

  final DownloadTask task;
  final VoidCallback onTap;

  String _getStageTitle(DownloadTask task) {
    final stage = task.progress.stage;
    return switch (stage) {
      Stages.decrypting => 'Расшифровка глав',
      Stages.parsing => 'Построение структуры',
      Stages.imageDownloading => 'Загрузка изображений',
      Stages.downloading => 'Загрузка глав',
      Stages.building => 'Сборка книги',
      Stages.ziping => 'Упаковка архива',
      Stages.analyzing => 'Анализ книги',
      Stages.done => 'Завершено',
      Stages.error => 'Ошибка',
      _ => 'Подготовка...',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Observer(
      builder: (_) {
        final meta = task.metadata;
        final title = meta?.title ?? 'Загрузка книги #${task.bookId}...';
        final coverUrl = meta?.cover?.ref.id;
        final isCompleted = task.isCompleted;
        final isActive = task.isActive;
        final isFailed = task.isFailed;

        final cur = task.progress.current ?? 0;
        final tot = task.progress.total ?? 0;
        final progressVal = (tot > 0) ? (cur / tot).clamp(0.0, 1.0) : null;
        final stageTitle = _getStageTitle(task);

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
                  // Book Cover
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    child: (coverUrl != null && coverUrl.isNotEmpty)
                        ? CachedNetworkImage(
                            imageUrl: coverUrl,
                            width: 44,
                            height: 60,
                            fit: BoxFit.cover,
                            errorWidget: (_, _, _) => Container(
                              width: 44,
                              height: 60,
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.book_rounded,
                                size: 22,
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          )
                        : Container(
                            width: 44,
                            height: 60,
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.book_rounded,
                              size: 22,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                  ),
                  const SizedBox(width: 14),

                  // Title and status/progress
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
                                  stageTitle,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (tot > 0 && progressVal != null) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '${(progressVal * 100).toInt()}%',
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
                            value: progressVal,
                            height: 6,
                            strokeWidth: 3,
                            backgroundColor: theme.colorScheme.primary
                                .withValues(alpha: 0.15),
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
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
