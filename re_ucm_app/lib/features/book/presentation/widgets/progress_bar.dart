import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:re_ucm_core/models/progress.dart';
import '../../../../core/ui/constants.dart';
import '../../../common/widgets/outlined_btn.dart';
import '../book_page_controller.cg.dart';

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
            Stages.imageDownloading => _buildImageDownloadingPanel(
              context,
              progress,
            ),
            Stages.error => Text(progress.message ?? 'Произошла ошибка'),
            _ =>
              controller.failedTasks.isEmpty
                  ? const SizedBox(height: appPadding * 2)
                  : _buildFailedPanel(context),
          },
        );
      },
    );
  }

  Widget _buildImageDownloadingPanel(BuildContext context, Progress progress) {
    final current = progress.current ?? 0;
    final total = progress.total ?? 0;
    final double? totalProgressVal = (total > 0)
        ? (current / total).clamp(0.0, 1.0)
        : null;

    final visibleTasks = progress.activeTasks
        .where((task) => task.status != ImageDownloadStatus.completed)
        .toList();

    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: appPadding * 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cardBorderRadius),
        border: Border.all(color: theme.colorScheme.primary, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(appPadding * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Загрузка изображений:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  total > 0 ? '$current из $total' : 'Инициализация...',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: appPadding),
            LinearProgressIndicator(
              borderRadius: BorderRadius.circular(90),
              value: totalProgressVal,
            ),
            if (visibleTasks.isNotEmpty) ...[
              const SizedBox(height: appPadding * 2),
              const Divider(height: 1),
              const SizedBox(height: appPadding),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: visibleTasks.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: appPadding),
                  itemBuilder: (context, index) {
                    final task = visibleTasks[index];
                    return _buildTaskRow(context, task);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTaskRow(BuildContext context, ImageDownloadTask task) {
    final theme = Theme.of(context);

    final (Widget statusIcon, String statusText) = switch (task.status) {
      ImageDownloadStatus.completed => (
        Icon(Icons.check_circle, size: 16, color: Colors.green.shade400),
        _formatBytes(task.receivedBytes),
      ),
      ImageDownloadStatus.failed => (
        Icon(Icons.error, size: 16, color: theme.colorScheme.error),
        'Ошибка',
      ),
      ImageDownloadStatus.downloading => (
        SizedBox(
          width: 18,
          height: 18,
          child: Padding(
            padding: const EdgeInsets.all(1),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        task.totalBytes != null
            ? '${_formatBytes(task.receivedBytes)} / ${_formatBytes(task.totalBytes!)}'
            : _formatBytes(task.receivedBytes),
      ),
      ImageDownloadStatus.pending => (
        Icon(Icons.schedule, size: 16, color: theme.disabledColor),
        'В очереди',
      ),
    };

    return SizedBox(
      height: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 24,
            child: Row(
              children: [
                statusIcon,
                const SizedBox(width: appPadding),
                Expanded(
                  child: Text(
                    task.id,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                const SizedBox(width: appPadding),
                Text(
                  statusText,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                task.status == ImageDownloadStatus.downloading &&
                    task.progress != null
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: double.infinity,
                      height: 2,
                      child: LinearProgressIndicator(
                        value: task.progress,
                        minHeight: 2,
                        borderRadius: BorderRadius.circular(1),
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildFailedPanel(BuildContext context) {
    final theme = Theme.of(context);
    final tasks = controller.failedTasks;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: appPadding * 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cardBorderRadius),
        border: Border.all(color: theme.colorScheme.error, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(appPadding * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 18,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: appPadding),
                const Text(
                  'Не удалось загрузить изображения:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: appPadding),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: tasks.length,
                separatorBuilder: (_, _) => const SizedBox(height: appPadding),
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return Row(
                    children: [
                      Icon(
                        Icons.error,
                        size: 16,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: appPadding),
                      Expanded(
                        child: Text(
                          task.id,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: appPadding * 2),
            OutlinedButton1(
              text: 'Повторить',
              isLoading: controller.isDownloading,
              func: controller.download,
            ),
          ],
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
