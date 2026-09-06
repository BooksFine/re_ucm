import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';
import 'package:text_balancer/text_balancer.dart';

import '../../../core/di.dart';
import '../../../core/navigation/router_delegate.dart';
import '../../../core/ui/tokens.dart';
import '../../../core/ui/widgets/m3e_spring_popup.dart';
import 'recent_book_actions.dart';

class RecentBookCard extends StatefulWidget {
  const RecentBookCard({
    super.key,
    required this.book,
    this.onDelete,
    this.isWide = false,
  });

  final RecentBook book;
  final VoidCallback? onDelete;
  final bool isWide;

  @override
  State<RecentBookCard> createState() => _RecentBookCardState();
}

class _RecentBookCardState extends State<RecentBookCard> {
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

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(
              color: state.isDownloading
                  ? cs.primary.withValues(alpha: 0.4)
                  : cs.outlineVariant.withValues(alpha: 0.35),
              width: state.isDownloading ? 1.2 : 0.6,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book Cover
                  buildCover(
                    context,
                    cs,
                    widget.book,
                    width: 68,
                    height: 98,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Book Information and Actions
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: Title and More actions button
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextBalancer(
                                    widget.book.title,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          height: 1.2,
                                        ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    widget.book.authors,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: cs.onSurfaceVariant,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),

                            // Quick Share button (always accessible with ergonomic touch target)
                            IconButton(
                              tooltip: 'Поделиться',
                              icon: Icon(
                                Icons.share_outlined,
                                size: 20,
                                color: cs.onSurfaceVariant,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                              onPressed: () => shareBook(
                                context,
                                task,
                                effectiveFilePath,
                                widget.book,
                              ),
                            ),

                            // More options menu (Open in browser, Delete)
                            _buildMoreMenu(context, cs),
                          ],
                        ),

                        // Series info if present (placed above badges)
                        if (widget.book.seriesName != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            '${widget.book.seriesName!} #${widget.book.seriesNumber ?? 1}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        // Badges row: Portal badge and Downloaded date badge
                        const SizedBox(height: 6),
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
                                  prefix: 'Скачано',
                                ) case final badge?)
                              badge,
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Bottom Actions: Read file button (if available) and Split Download Button
                        Builder(
                          builder: (context) {
                            return Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: AppSpacing.xs,
                              runSpacing: AppSpacing.xs,
                              children: [
                                if (state.fileExists)
                                  M3EButton.icon(
                                    style: M3EButtonStyle.tonal,
                                    size: M3EButtonSize.sm,
                                    shape: M3EButtonShape.round,
                                    icon: const Icon(Icons.menu_book_rounded),
                                    label: const Text('Читать'),
                                    onPressed: () => openBook(
                                      context,
                                      task: task,
                                      effectiveFilePath: effectiveFilePath,
                                    ),
                                  ),

                                // Primary Action: M3E Split Button for download & format
                                M3EButton.icon(
                                  style: M3EButtonStyle.tonal,
                                  size: M3EButtonSize.sm,
                                  shape: M3EButtonShape.round,
                                  icon: const Icon(Icons.download_rounded),
                                  label: const Text('Скачать'),
                                  onPressed: () {
                                    startDownload(
                                      context,
                                      session,
                                      effectiveFormat,
                                      widget.book.id,
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMoreMenu(BuildContext context, ColorScheme cs) {
    return Builder(
      builder: (btnContext) {
        return IconButton(
          tooltip: 'Дополнительно',
          icon: Icon(
            Icons.more_vert_rounded,
            size: 20,
            color: cs.onSurfaceVariant,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          onPressed: () async {
            HapticFeedback.lightImpact();
            final action = await showM3ESpringPopup<String>(
              targetContext: btnContext,
              items: const [
                M3ESpringPopupItem<String>(
                  value: 'browser',
                  label: 'Открыть в браузере',
                  icon: Icons.open_in_browser_rounded,
                ),
                M3ESpringPopupItem<String>(
                  value: 'delete',
                  label: 'Удалить',
                  icon: Icons.delete_outline_rounded,
                  isDestructive: true,
                ),
              ],
            );

            if (action == 'browser') {
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
