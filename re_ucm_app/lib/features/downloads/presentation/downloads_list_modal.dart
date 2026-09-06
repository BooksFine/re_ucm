import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di.dart';
import '../../../core/ui/responsive_modal.dart';
import '../domain/download_task.cg.dart';
import 'download_modal.dart';
import 'widgets/download_list_tile.dart';

Future<void> showDownloadsListModal(BuildContext context) async {
  await showResponsiveAppModal(
    context,
    dialogMaxWidth: 520,
    dialogMaxHeight: 620,
    dialogPadding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
    dialogScrollable: false,
    sheetMaxHeightFraction: 0.75,
    sheetScrollable: false,
    contentBuilder: (contentCtx, close, isWide) =>
        DownloadsListContent(isWide: isWide, onClose: close),
  );
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

    // Внешний Observer — только ids/counts. Ряды — per-item Observer
    // внутри DownloadListTile, прогресс не ребилдит весь список.
    return Observer(
      builder: (context) {
        final taskKeys = downloadsService.tasks.keys.toList();
        final activeTasks = downloadsService.activeTasks;
        final completedTasks = downloadsService.completedTasks;
        final total = downloadsService.totalCount;

        if (taskKeys.isEmpty) {
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
                    '$total',
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
                  if (activeTasks.isNotEmpty)
                    _TaskSection(
                      title: 'АКТИВНЫЕ (${activeTasks.length})',
                      tasks: activeTasks,
                      onTap: (task) {
                        onClose();
                        showDownloadModalForTask(context, task);
                      },
                    ),
                  if (activeTasks.isNotEmpty && completedTasks.isNotEmpty)
                    const SizedBox(height: 16),
                  if (completedTasks.isNotEmpty)
                    _TaskSection(
                      title: 'ЗАВЕРШЁННЫЕ (${completedTasks.length})',
                      tasks: completedTasks,
                      onTap: (task) {
                        onClose();
                        showDownloadModalForTask(context, task);
                      },
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TaskSection extends StatelessWidget {
  const _TaskSection({
    required this.title,
    required this.tasks,
    required this.onTap,
  });

  final String title;
  final List<DownloadTask> tasks;
  final void Function(DownloadTask task) onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(height: 8),
        for (final task in tasks)
          DownloadListTile(
            key: downloadTileKey(task),
            task: task,
            onTap: () => onTap(task),
          ),
      ],
    );
  }
}
