import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:re_ucm_core/models/progress.dart';
import '../../../../../core/ui/constants.dart';
import '../../book_page_controller.cg.dart';
import 'failed_tasks_panel.dart';
import 'progress_card.dart';
import 'task_row.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.controller});

  final BookPageController controller;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final progress = controller.progress;

        return AnimatedSize(
          duration: Durations.short4,
          alignment: Alignment.topCenter,
          child: switch (progress.stage) {
            Stages.downloading => _buildChapterDownloadingPanel(
              context,
              progress,
            ),
            Stages.imageDownloading => _buildImageDownloadingPanel(
              context,
              progress,
            ),
            Stages.error => Text(progress.message ?? 'Произошла ошибка'),
            _ =>
              controller.failedTasks.isEmpty
                  ? const SizedBox(height: appPadding * 2)
                  : FailedTasksPanel(
                      tasks: controller.failedTasks,
                      isLoading: controller.isDownloading,
                      onRetry: controller.download,
                    ),
          },
        );
      },
    );
  }

  Widget _buildChapterDownloadingPanel(
    BuildContext context,
    Progress progress,
  ) {
    final visibleTasks = progress.chapterTasks
        .where((task) => task.status != ChapterDownloadStatus.completed)
        .toList();
    final theme = Theme.of(context);

    return ProgressCard<ChapterDownloadTask>(
      title: 'Загрузка глав:',
      current: progress.current,
      total: progress.total,
      message: progress.message,
      items: visibleTasks,
      itemBuilder: (context, task) => TaskRow(
        status: switch (task.status) {
          ChapterDownloadStatus.completed => TaskRowStatus.completed,
          ChapterDownloadStatus.failed => TaskRowStatus.failed,
          ChapterDownloadStatus.downloading => TaskRowStatus.downloading,
          ChapterDownloadStatus.pending => TaskRowStatus.pending,
        },
        prefix: Text(
          '#${task.index}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        title: task.title,
        statusText: switch (task.status) {
          ChapterDownloadStatus.completed => 'Готово',
          ChapterDownloadStatus.failed => 'Ошибка',
          ChapterDownloadStatus.downloading => 'Загрузка...',
          ChapterDownloadStatus.pending => 'В очереди',
        },
      ),
    );
  }

  Widget _buildImageDownloadingPanel(BuildContext context, Progress progress) {
    final visibleTasks = progress.activeTasks
        .where((task) => task.status != ImageDownloadStatus.completed)
        .toList();

    return ProgressCard<ImageDownloadTask>(
      title: 'Загрузка изображений:',
      current: progress.current,
      total: progress.total,
      message: progress.message,
      items: visibleTasks,
      itemBuilder: (context, task) => TaskRow(
        status: switch (task.status) {
          ImageDownloadStatus.completed => TaskRowStatus.completed,
          ImageDownloadStatus.failed => TaskRowStatus.failed,
          ImageDownloadStatus.downloading => TaskRowStatus.downloading,
          ImageDownloadStatus.pending => TaskRowStatus.pending,
        },
        title: task.id,
        statusText: switch (task.status) {
          ImageDownloadStatus.completed => _formatBytes(task.receivedBytes),
          ImageDownloadStatus.failed => 'Ошибка',
          ImageDownloadStatus.downloading =>
            task.totalBytes != null
                ? '${_formatBytes(task.receivedBytes)} / ${_formatBytes(task.totalBytes!)}'
                : _formatBytes(task.receivedBytes),
          ImageDownloadStatus.pending => 'В очереди',
        },
        progress: task.progress,
      ),
    );
  }

  static String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
