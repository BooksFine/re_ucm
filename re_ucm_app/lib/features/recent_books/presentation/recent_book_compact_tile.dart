import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../core/di.dart';
import '../../../core/navigation/router_delegate.dart';
import '../../../core/ui/tokens.dart';
import '../../../core/ui/widgets/m3e_spring_popup.dart';
import '../../downloads/domain/download_task.cg.dart';
import 'recent_book_actions.dart';

class RecentBookCompactTile extends StatefulWidget {
  const RecentBookCompactTile({super.key, required this.book, this.onDelete});

  final RecentBook book;
  final VoidCallback? onDelete;

  @override
  State<RecentBookCompactTile> createState() => _RecentBookCompactTileState();
}

class _RecentBookCompactTileState extends State<RecentBookCompactTile> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final deps = AppDependencies.of(context);
    final downloadsService = deps.downloadsService;
    final settingsService = deps.settingsService;

    final session = settingsService.sessionByCode(widget.book.portal.code);

    return Observer(
      builder: (context) {
        final state = RecentBookItemState.resolve(
          widget.book,
          downloadsService,
        );
        final effectiveFormat = getEffectiveFormat(widget.book, settingsService);
        final task = state.task;
        final effectiveFilePath = state.effectiveFilePath;

        double? progress;
        if (state.isDownloading && task != null) {
          final cur = task.progress.current;
          final tot = task.progress.total;
          if (cur != null && tot != null && tot > 0) {
            progress = (cur / tot).clamp(0.0, 1.0);
          }
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(
              color: state.isDownloading
                  ? cs.primary.withValues(alpha: 0.45)
                  : cs.outlineVariant.withValues(alpha: 0.35),
              width: state.isDownloading ? 1.2 : 0.6,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Book Cover (46 x 66)
                buildCover(
                  context,
                  cs,
                  widget.book,
                  width: 46,
                  height: 66,
                  iconSize: 20,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                const SizedBox(width: 12),

                // Information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.book.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.book.seriesName != null
                            ? '${widget.book.authors} • ${widget.book.seriesName!} #${widget.book.seriesNumber ?? 1}'
                            : widget.book.authors,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Badges & status
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          buildPortalBadge(context, widget.book.portal),
                          if (buildDownloadedBadge(
                                context,
                                downloadedAt: state.downloadedAt,
                                isVisible: state.fileExists,
                              ) case final badge?)
                            badge
                          else if (state.isDownloading)
                            Text(
                              progress != null
                                  ? 'Загрузка ${(progress * 100).toInt()}%'
                                  : 'Загрузка...',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 10,
                                color: cs.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Actions
                if (state.isDownloading) ...[
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: M3ECircularWavyProgressIndicator(
                      value: progress,
                      size: 22,
                      strokeWidth: 2.2,
                      color: cs.primary,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Отменить',
                    icon: const Icon(Icons.close_rounded, size: 20),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: () => task?.cancel(),
                  ),
                ] else ...[
                  // Primary "Скачать" button — full-width/prominent with text and icon
                  M3EButton.icon(
                    style: M3EButtonStyle.tonal,
                    size: M3EButtonSize.xs,
                    shape: M3EButtonShape.round,
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Скачать'),
                    onPressed: () {
                      startDownload(context, session, effectiveFormat, widget.book.id);
                    },
                  ),

                  // More popup menu
                  _buildMoreMenu(
                    context,
                    cs,
                    task,
                    effectiveFilePath,
                    state.fileExists,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMoreMenu(
    BuildContext context,
    ColorScheme cs,
    DownloadTask? task,
    String? effectiveFilePath,
    bool fileExists,
  ) {
    return Builder(
      builder: (btnContext) {
        return IconButton(
          tooltip: 'Дополнительно',
          icon: Icon(
            Icons.more_vert_rounded,
            size: 20,
            color: cs.onSurfaceVariant,
          ),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 36),
          onPressed: () async {
            HapticFeedback.lightImpact();
            final action = await showM3ESpringPopup<String>(
              targetContext: btnContext,
              items: [
                if (fileExists)
                  const M3ESpringPopupItem<String>(
                    value: 'open',
                    label: 'Читать',
                    icon: Icons.menu_book_rounded,
                  ),
                const M3ESpringPopupItem<String>(
                  value: 'share',
                  label: 'Поделиться',
                  icon: Icons.share_outlined,
                ),
                const M3ESpringPopupItem<String>(
                  value: 'browser',
                  label: 'Открыть на сайте',
                  icon: Icons.open_in_browser_rounded,
                ),
                const M3ESpringPopupItem<String>(
                  value: 'delete',
                  label: 'Удалить',
                  icon: Icons.delete_outline_rounded,
                  isDestructive: true,
                ),
              ],
            );

            if (!context.mounted) return;

            if (action == 'open') {
              await openBook(
                context,
                task: task,
                effectiveFilePath: effectiveFilePath,
              );
            } else if (action == 'share') {
              shareBook(context, task, effectiveFilePath, widget.book);
            } else if (action == 'browser') {
              Nav.goBrowser(widget.book.portal.code);
            } else if (action == 'delete') {
              widget.onDelete?.call();
            }
          },
        );
      },
    );
  }
}
