import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/models/progress.dart';

import '../../../../core/ui/formatters.dart';
import '../../../../core/ui/widgets/app_progress_card.dart';
import '../../domain/download_task.cg.dart';
import 'download_task_row.dart';

class DownloadProgressCard extends StatelessWidget {
  const DownloadProgressCard({
    super.key,
    required this.task,
    this.isWide = false,
  });

  final DownloadTask task;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Observer(
      builder: (context) {
        final progress = task.progress;
        final cur = progress.current ?? 0;
        final tot = progress.total ?? 0;
        final double? progressVal = task.normalizedProgress;

        final stageTitle = progress.stage.title;

        final nonCompletedChapters = <ChapterDownloadTask>[];
        for (final t in progress.chapterTasks) {
          if (t.status != ChapterDownloadStatus.completed) {
            nonCompletedChapters.add(t);
          }
        }

        final nonCompletedImages = <ImageDownloadTask>[];
        for (final t in progress.activeTasks) {
          if (t.status != ImageDownloadStatus.completed) {
            nonCompletedImages.add(t);
          }
        }

        final hasChapters =
            (progress.stage == Stages.downloading ||
                progress.stage == Stages.decrypting ||
                progress.stage == Stages.parsing) &&
            nonCompletedChapters.isNotEmpty;

        final hasImages =
            progress.stage == Stages.imageDownloading &&
            nonCompletedImages.isNotEmpty;

        final hasDetails = hasChapters || hasImages;

        final statusText = tot > 0
            ? '$cur / $tot${progressVal != null ? ' (${(progressVal * 100).toInt()}%)' : ''}'
            : (progress.message ?? 'Инициализация...');

        final Widget? expandedContent = hasDetails
            ? Padding(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: isWide ? 170 : 130),
                  child: hasChapters
                      ? _buildChaptersList(theme, nonCompletedChapters)
                      : _buildImagesList(theme, nonCompletedImages),
                ),
              )
            : null;

        return AppProgressCard(
          title: stageTitle,
          statusText: statusText,
          progress: progressVal,
          expandedChild: expandedContent,
          initiallyExpanded: true,
        );
      },
    );
  }

  Widget _buildChaptersList(ThemeData theme, List<ChapterDownloadTask> tasks) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemExtent: 26,
      primary: false,
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return DownloadTaskRow(
          status: switch (task.status) {
            ChapterDownloadStatus.downloading =>
              DownloadTaskStatus.downloading,
            ChapterDownloadStatus.completed => DownloadTaskStatus.completed,
            ChapterDownloadStatus.failed => DownloadTaskStatus.failed,
            ChapterDownloadStatus.pending => DownloadTaskStatus.idle,
          },
          prefix: Text(
            '#${task.index}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          title: task.title,
          statusText: switch (task.status) {
            ChapterDownloadStatus.downloading => 'Загрузка...',
            ChapterDownloadStatus.completed => 'Готово',
            ChapterDownloadStatus.failed => 'Ошибка',
            ChapterDownloadStatus.pending => 'В очереди',
          },
        );
      },
    );
  }

  Widget _buildImagesList(ThemeData theme, List<ImageDownloadTask> tasks) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemExtent: 32,
      primary: false,
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final percentText = task.progress != null
            ? ' (${(task.progress! * 100).toInt()}%)'
            : '';
        final statusText = switch (task.status) {
          ImageDownloadStatus.downloading =>
            task.totalBytes != null
                ? '${formatBytes(task.receivedBytes)} / ${formatBytes(task.totalBytes!)}$percentText'
                : formatBytes(task.receivedBytes),
          ImageDownloadStatus.completed => formatBytes(task.receivedBytes),
          ImageDownloadStatus.failed => 'Ошибка',
          ImageDownloadStatus.pending => 'В очереди',
        };

        return DownloadTaskRow(
          status: switch (task.status) {
            ImageDownloadStatus.downloading =>
              DownloadTaskStatus.downloading,
            ImageDownloadStatus.completed => DownloadTaskStatus.completed,
            ImageDownloadStatus.failed => DownloadTaskStatus.failed,
            ImageDownloadStatus.pending => DownloadTaskStatus.idle,
          },
          title: task.id,
          statusText: statusText,
          progress: task.progress,
        );
      },
    );
  }

}
