import 'package:dart_book/dart_book.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../core/di.dart';
import '../../../core/ui/responsive_modal.dart';
import '../domain/download_task.cg.dart';

import 'widgets/download_actions.dart';
import 'widgets/download_book_header.dart';
import 'widgets/download_options_card.dart';
import 'widgets/download_progress_card.dart';
import 'widgets/failed_tasks_card.dart';

/// Реестр открытых модалок. Раньше флаг `isModalOpen` жил в domain-сторе —
/// UI-состояние не должно храниться в [DownloadTask].
final Set<DownloadTask> _openModals = {};

Future<void> showDownloadModal(
  BuildContext context, {
  required PortalSession session,
  required String bookId,
  BookMetadata? initialMetadata,
}) async {
  final downloadsService = AppDependencies.of(context).downloadsService;
  final task = downloadsService.startDownload(
    session: session,
    bookId: bookId,
    initialMetadata: initialMetadata,
  );

  await showDownloadModalForTask(context, task);
}

Future<void> showDownloadModalForTask(
  BuildContext context,
  DownloadTask task,
) async {
  if (_openModals.contains(task)) return;
  _openModals.add(task);

  try {
    await showResponsiveAppModal(
      context,
      dialogMaxWidth: 460,
      contentBuilder: (contentCtx, close, isWide) =>
          DownloadModalContent(task: task, isWide: isWide, onClose: close),
    );
  } finally {
    _openModals.remove(task);
  }
}

class DownloadModalContent extends StatelessWidget {
  const DownloadModalContent({
    super.key,
    required this.task,
    required this.onClose,
    this.isWide = false,
  });

  final DownloadTask task;
  final VoidCallback onClose;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOutCubic,
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Book Header (smooth cross-fade from skeleton to loaded header)
          Observer(
            builder: (_) {
              final meta = task.metadata;
              return AnimatedCrossFade(
                duration: const Duration(milliseconds: 320),
                firstCurve: Curves.easeInOutCubic,
                secondCurve: Curves.easeInOutCubic,
                sizeCurve: Curves.easeInOutCubic,
                crossFadeState: meta != null
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: DownloadBookHeaderSkeleton(isWide: isWide),
                secondChild: meta != null
                    ? RepaintBoundary(
                        child: DownloadBookHeader(
                          book: meta,
                          portal: task.session.portal,
                          isWide: isWide,
                        ),
                      )
                    : const SizedBox.shrink(),
              );
            },
          ),


          // Progress card (smooth animated collapse inside card, outer layout smoothly adapted)
          Observer(
            builder: (_) {
              if (!task.isActive) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: DownloadProgressCard(task: task, isWide: isWide),
              );
            },
          ),

          // Failed tasks card (smooth collapse/expand)
          Observer(
            builder: (_) {
              return AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                alignment: Alignment.topCenter,
                child: task.failedTasks.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: FailedTasksCard(
                          tasks: task.failedTasks,
                          isLoading: task.isActive,
                          onRetry: task.retryFailedImages,
                          onIgnore: task.ignoreFailedTasks,
                        ),
                      )
                    : const SizedBox.shrink(),
              );
            },
          ),

          // Options checkboxes (never rebuilds on progress!)
          const SizedBox(height: 12),
          DownloadOptionsCard(task: task),

          // Contextual actions
          const SizedBox(height: 14),
          DownloadActions(task: task, onClose: onClose),
        ],
      ),
    );
  }
}
