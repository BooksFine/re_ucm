import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/models/progress.dart';

import '../../../../core/ui/formatters.dart';
import '../../../../core/ui/widgets/app_card.dart';
import '../../../../core/ui/widgets/app_progress_card.dart';
import '../../domain/download_task.cg.dart';
import '../models/download_status_viewmodel.dart';
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
    return Observer(
      builder: (context) {
        // Единая формула через viewModel.
        final vm = task.viewModel;
        final progress = task.progress;

        final isChapterStage =
            progress.stage == Stages.downloading ||
            progress.stage == Stages.decrypting ||
            progress.stage == Stages.parsing;
        final isImageStage = progress.stage == Stages.imageDownloading;

        final nonCompletedChapters = isChapterStage
            ? [
                for (final t in progress.chapterTasks)
                  if (t.status != ChapterDownloadStatus.completed) t,
              ]
            : const <ChapterDownloadTask>[];

        final nonCompletedImages = isImageStage
            ? [
                for (final t in progress.activeTasks)
                  if (t.status != ImageDownloadStatus.completed) t,
              ]
            : const <ImageDownloadTask>[];

        final hasChapters = isChapterStage && nonCompletedChapters.isNotEmpty;
        final hasImages = isImageStage && nonCompletedImages.isNotEmpty;
        final hasDetails = hasChapters || hasImages;

        final statusText = progress.total != null && progress.total! > 0
            ? progress.counterText
            : (progress.message ?? 'Инициализация...');

        final Widget? expandedContent = hasDetails
            ? Padding(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: isWide ? 170 : 130),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemExtent: hasChapters ? 26 : 32,
                    primary: false,
                    itemCount: hasChapters
                        ? nonCompletedChapters.length
                        : nonCompletedImages.length,
                    itemBuilder: (context, index) {
                      if (hasChapters) {
                        return _buildChapterRow(
                          context,
                          nonCompletedChapters[index],
                        );
                      }
                      return _buildImageRow(nonCompletedImages[index]);
                    },
                  ),
                ),
              )
            : null;

        return AppProgressCard(
          titleWidget: AppCardTitle.text(
            progress.stage.title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          statusWidget: Text(
            statusText,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          progress: vm.progress,
          expandedChild: expandedContent,
          initiallyExpanded: true,
        );
      },
    );
  }

  Widget _buildChapterRow(BuildContext context, ChapterDownloadTask task) {
    final theme = Theme.of(context);
    final statusText = switch (task.status) {
      ChapterDownloadStatus.downloading => 'Загрузка...',
      ChapterDownloadStatus.completed => 'Готово',
      ChapterDownloadStatus.failed => 'Ошибка',
      ChapterDownloadStatus.pending => 'В очереди',
    };
    return DownloadTaskRow(
      title: task.title,
      statusText: statusText,
      prefix: Text(
        '#${task.index}',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
      isDownloading: task.status == ChapterDownloadStatus.downloading,
      isCompleted: task.status == ChapterDownloadStatus.completed,
      isFailed: task.status == ChapterDownloadStatus.failed,
    );
  }

  Widget _buildImageRow(ImageDownloadTask task) {
    final statusText = switch (task.status) {
      ImageDownloadStatus.downloading => formatProgressBytes(
        task.receivedBytes,
        task.totalBytes,
      ),
      ImageDownloadStatus.completed => formatProgressBytes(
        task.receivedBytes,
        task.totalBytes,
      ),
      ImageDownloadStatus.failed => 'Ошибка',
      ImageDownloadStatus.pending => 'В очереди',
    };
    return DownloadTaskRow(
      title: task.id,
      statusText: statusText,
      progress: task.progress,
      isDownloading: task.status == ImageDownloadStatus.downloading,
      isCompleted: task.status == ImageDownloadStatus.completed,
      isFailed: task.status == ImageDownloadStatus.failed,
    );
  }
}
