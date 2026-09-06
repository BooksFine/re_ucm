import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/models/progress.dart';

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
        final double? progressVal =
            (tot > 0) ? (cur / tot).clamp(0.0, 1.0) : null;

        final stageTitle = switch (progress.stage) {
          Stages.decrypting => 'Расшифровка глав',
          Stages.parsing => 'Построение структуры',
          Stages.imageDownloading => 'Загрузка изображений',
          Stages.downloading => 'Загрузка глав',
          Stages.building => 'Сборка книги',
          Stages.ziping => 'Упаковка архива',
          Stages.analyzing => 'Анализ книги',
          Stages.done => 'Загрузка завершена',
          Stages.error => 'Ошибка',
          _ => 'Подготовка...',
        };

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
              DownloadTaskRowStatus.downloading,
            ChapterDownloadStatus.completed => DownloadTaskRowStatus.completed,
            ChapterDownloadStatus.failed => DownloadTaskRowStatus.failed,
            ChapterDownloadStatus.pending => DownloadTaskRowStatus.pending,
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
                ? '${_formatBytes(task.receivedBytes)} / ${_formatBytes(task.totalBytes!)}$percentText'
                : _formatBytes(task.receivedBytes),
          ImageDownloadStatus.completed => _formatBytes(task.receivedBytes),
          ImageDownloadStatus.failed => 'Ошибка',
          ImageDownloadStatus.pending => 'В очереди',
        };

        return DownloadTaskRow(
          status: switch (task.status) {
            ImageDownloadStatus.downloading =>
              DownloadTaskRowStatus.downloading,
            ImageDownloadStatus.completed => DownloadTaskRowStatus.completed,
            ImageDownloadStatus.failed => DownloadTaskRowStatus.failed,
            ImageDownloadStatus.pending => DownloadTaskRowStatus.pending,
          },
          title: task.id,
          statusText: statusText,
          progress: task.progress,
        );
      },
    );
  }

  static String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }
}
