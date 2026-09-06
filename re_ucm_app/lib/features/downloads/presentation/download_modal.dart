import 'package:dart_book/dart_book.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../core/di.dart';
import '../../../core/ui/tokens.dart';
import '../domain/download_task.cg.dart';

import 'widgets/download_actions.dart';
import 'widgets/download_book_header.dart';
import 'widgets/download_options_card.dart';
import 'widgets/download_progress_card.dart';
import 'widgets/failed_tasks_card.dart';

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
  if (task.isModalOpen) return;
  task.isModalOpen = true;

  try {
    final isWide = MediaQuery.sizeOf(context).width >= 600;
    if (isWide) {
      await showDialog(
        context: context,
        builder: (dialogCtx) => Dialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.dialog),
          ),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: DownloadModalContent(
                    task: task,
                    isWide: true,
                    onClose: () => Navigator.of(dialogCtx).pop(),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    onPressed: () => Navigator.of(dialogCtx).pop(),
                    tooltip: 'Закрыть',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      await showM3EModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        builder: (sheetCtx) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              0,
              16,
              MediaQuery.viewInsetsOf(sheetCtx).bottom + 16,
            ),
            child: SingleChildScrollView(
              child: DownloadModalContent(
                task: task,
                isWide: false,
                onClose: () => Navigator.of(sheetCtx).pop(),
              ),
            ),
          ),
        ),
      );
    }
  } finally {
    task.isModalOpen = false;
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
