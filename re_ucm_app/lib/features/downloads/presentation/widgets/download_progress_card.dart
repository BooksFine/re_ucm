import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/models/progress.dart';

import '../../../../core/ui/widgets/app_card.dart';
import '../../../../core/ui/widgets/app_progress_card.dart';
import '../../domain/download_task.cg.dart';
import '../models/download_status_viewmodel.dart';
import 'download_progress_format.dart';
import 'download_task_row.dart';

/// Строка для единого [_buildRows].
class DownloadRowModel {
  const DownloadRowModel({
    required this.status,
    required this.title,
    required this.statusText,
    this.prefix,
    this.progress,
  });

  final DownloadTaskStatus status;
  final String title;
  final String statusText;
  final Widget? prefix;
  final double? progress;
}

extension ChapterRowModel on ChapterDownloadTask {
  DownloadRowModel toRowModel() {
    return DownloadRowModel(
      status: switch (status) {
        ChapterDownloadStatus.downloading => DownloadTaskStatus.downloading,
        ChapterDownloadStatus.completed => DownloadTaskStatus.completed,
        ChapterDownloadStatus.failed => DownloadTaskStatus.failed,
        ChapterDownloadStatus.pending => DownloadTaskStatus.idle,
      },
      title: title,
      statusText: switch (status) {
        ChapterDownloadStatus.downloading => 'Загрузка...',
        ChapterDownloadStatus.completed => 'Готово',
        ChapterDownloadStatus.failed => 'Ошибка',
        ChapterDownloadStatus.pending => 'В очереди',
      },
      prefix: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Text(
            '#$index',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          );
        },
      ),
    );
  }
}

extension ImageRowModel on ImageDownloadTask {
  DownloadRowModel toRowModel() {
    final statusText = switch (status) {
      ImageDownloadStatus.downloading => formatProgressBytes(
        receivedBytes,
        totalBytes,
      ),
      ImageDownloadStatus.completed => formatProgressBytes(
        receivedBytes,
        totalBytes,
      ),
      ImageDownloadStatus.failed => 'Ошибка',
      ImageDownloadStatus.pending => 'В очереди',
    };
    return DownloadRowModel(
      status: switch (status) {
        ImageDownloadStatus.downloading => DownloadTaskStatus.downloading,
        ImageDownloadStatus.completed => DownloadTaskStatus.completed,
        ImageDownloadStatus.failed => DownloadTaskStatus.failed,
        ImageDownloadStatus.pending => DownloadTaskStatus.idle,
      },
      title: id,
      statusText: statusText,
      progress: progress,
    );
  }
}

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

        final statusText = progress.total != null && progress.total! > 0
            ? progress.counterText
            : (progress.message ?? 'Инициализация...');

        final rows = hasChapters
            ? nonCompletedChapters.map((e) => e.toRowModel()).toList()
            : nonCompletedImages.map((e) => e.toRowModel()).toList();

        final Widget? expandedContent = hasDetails
            ? Padding(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: isWide ? 170 : 130),
                  child: _buildRows(rows, hasChapters ? 26 : 32),
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

  /// Один ListView-builder для глав и картинок.
  Widget _buildRows(List<DownloadRowModel> rows, double itemExtent) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemExtent: itemExtent,
      primary: false,
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final row = rows[index];
        return DownloadTaskRow(
          status: row.status,
          prefix: row.prefix,
          title: row.title,
          statusText: row.statusText,
          progress: row.progress,
        );
      },
    );
  }
}
