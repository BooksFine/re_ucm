import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/models/progress.dart';

import '../../../../core/di.dart';
import '../../../../core/ui/tokens.dart';
import '../../../../core/ui/widgets/app_section_header.dart';
import '../../domain/download_task.cg.dart';
import '../download_modal.dart';

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
          duration: const Duration(milliseconds: 300),
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
                      // Task cards
                      for (final task in activeTasks)
                        _SingleActiveTaskCard(
                          key: ValueKey(task.session.portal.code + task.bookId),
                          task: task,
                          isWide: isWide,
                        ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _SingleActiveTaskCard extends StatelessWidget {
  const _SingleActiveTaskCard({
    super.key,
    required this.task,
    required this.isWide,
  });

  final DownloadTask task;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Observer(
      builder: (context) {
        final progress = task.progress;
        final cur = progress.current ?? 0;
        final tot = progress.total ?? 0;
        final double? progressVal = (tot > 0)
            ? (cur / tot).clamp(0.0, 1.0)
            : null;

        final stageTitle = switch (progress.stage) {
          Stages.decrypting => 'Расшифровка глав',
          Stages.parsing => 'Построение структуры',
          Stages.imageDownloading => 'Загрузка изображений',
          Stages.downloading => 'Загрузка глав',
          Stages.building => 'Сборка книги',
          Stages.ziping => 'Упаковка архива',
          Stages.analyzing => 'Анализ книги',
          Stages.done => 'Готово',
          Stages.error => 'Ошибка',
          _ => 'Подготовка...',
        };

        final statusText = tot > 0
            ? '$stageTitle: $cur/$tot${progressVal != null ? ' (${(progressVal * 100).toInt()}%)' : ''}'
            : (progress.message ?? stageTitle);

        final meta = task.metadata;
        final title = meta?.title ?? 'Книга #${task.bookId}';
        final authors =
            meta?.contributors
                .map((e) => e.name.toDisplayString())
                .join(', ') ??
            task.session.portal.name;
        final coverUrl = meta?.cover?.ref.id;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: cs.primaryContainer.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(
              color: cs.primary.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadii.card),
              onTap: () => showDownloadModalForTask(context, task),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Cover thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                          child: coverUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: coverUrl,
                                  width: 38,
                                  height: 52,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, error, stackTrace) =>
                                      _coverFallback(cs),
                                )
                              : _coverFallback(cs),
                        ),
                        const SizedBox(width: AppSpacing.md),

                        // Title, authors and stage
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                authors,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                statusText,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),

                        // Cancel button
                        IconButton(
                          tooltip: 'Отменить загрузку',
                          icon: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: cs.error,
                          ),
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(
                            minWidth: 44,
                            minHeight: 44,
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            task.cancel();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Progress bar
                    M3ELinearWavyProgressIndicator(
                      value: progressVal,
                      height: 6,
                      strokeWidth: 3,
                      color: cs.primary,
                      backgroundColor: cs.primary.withValues(alpha: 0.15),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _coverFallback(ColorScheme cs) {
    return Container(
      width: 38,
      height: 52,
      color: cs.surfaceContainerHighest,
      child: Icon(Icons.downloading_rounded, size: 20, color: cs.primary),
    );
  }
}
