import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/di.dart';
import '../../../../core/ui/tokens.dart';
import '../../../../core/ui/widgets/app_section_header.dart';
import '../download_modal.dart';
import 'download_list_tile.dart';

/// A live, non-blocking on-page card displaying active download tasks.
///
/// Features:
/// - Smooth animated expand/collapse (0 height when no active downloads)
/// - Real-time progress bar, stage indicator, chapter/image counts
/// - Cancel task button and quick details trigger
/// - Completed task quick-action (Open / Share)
class LiveDownloadCard extends StatelessWidget {
  const LiveDownloadCard({super.key, this.isWide = false});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final downloadsService = AppDependencies.of(context).downloadsService;

    return Observer(
      builder: (context) {
        final activeTasks = downloadsService.activeTasks;

        return AnimatedSize(
          duration: AppDurations.expand,
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: activeTasks.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Section header for active tasks
                      AppSectionHeader(
                        'Идет скачивание (${activeTasks.length})',
                        padding: EdgeInsets.fromLTRB(4, 0, 4, AppSpacing.sm),
                      ),
                      // Task cards — единый DownloadListTile(compact).
                      for (final task in activeTasks)
                        DownloadListTile(
                          key: downloadTileKey(task),
                          task: task,
                          compact: true,
                          onTap: () =>
                              showDownloadModalForTask(context, task),
                        ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
