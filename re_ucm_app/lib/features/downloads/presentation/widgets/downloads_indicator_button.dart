import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/di.dart';
import '../download_modal.dart';
import '../downloads_list_modal.dart';

class DownloadsIndicatorButton extends StatelessWidget {
  const DownloadsIndicatorButton({super.key});

  @override
  Widget build(BuildContext context) {
    final downloadsService = AppDependencies.of(context).downloadsService;
    final theme = Theme.of(context);

    return Observer(
      builder: (context) {
        final allTasks = downloadsService.allTasks;
        if (allTasks.isEmpty) return const SizedBox.shrink();

        final activeTasks = downloadsService.activeTasks;
        final hasActive = activeTasks.isNotEmpty;
        final totalProgress = downloadsService.totalProgress;

        void onTap() {
          // If exactly 1 task exists in total, go directly to its details
          if (allTasks.length == 1) {
            showDownloadModalForTask(context, allTasks.first);
          } else {
            // If multiple tasks exist, open the management list modal
            showDownloadsListModal(context);
          }
        }

        // Circular progress ring around the icon when downloading
        Widget iconContent = Stack(
          alignment: Alignment.center,
          children: [
            if (hasActive)
              SizedBox(
                width: 28,
                height: 28,
                child: M3ECircularWavyProgressIndicator(
                  value: totalProgress,
                  size: 28,
                  strokeWidth: 2.2,
                  color: theme.colorScheme.primary,
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.2,
                  ),
                ),
              ),
            Icon(
              hasActive
                  ? Icons.downloading_rounded
                  : Icons.download_done_rounded,
              size: 20,
              color: hasActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ],
        );

        Widget button = IconButton(
          tooltip: hasActive
              ? 'Загрузки (${activeTasks.length} акт.)'
              : 'Завершённые загрузки (${allTasks.length})',
          icon: iconContent,
          onPressed: onTap,
        );

        return Badge.count(
          count: hasActive ? activeTasks.length : allTasks.length,
          backgroundColor: hasActive
              ? theme.colorScheme.primary
              : theme.colorScheme.secondary,
          textColor: Colors.white,
          child: button,
        );
      },
    );
  }
}
