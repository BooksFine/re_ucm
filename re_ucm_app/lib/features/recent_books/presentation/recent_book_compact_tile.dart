import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:re_ucm_lib/re_ucm_lib.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/di.dart';
import '../../../core/navigation/router_delegate.dart';
import '../../../core/ui/tokens.dart';
import '../../../core/ui/widgets/m3e_spring_popup.dart';
import '../../common/widgets/overlay_snack.dart';
import '../../common/widgets/shimmer.dart';
import '../../downloads/domain/download_task.cg.dart';
import '../../downloads/domain/downloads_service.cg.dart';
import '../../downloads/presentation/download_modal.dart';
import '../../downloads/presentation/widgets/unauthorized_download_dialog.dart';

class RecentBookCompactTile extends StatefulWidget {
  const RecentBookCompactTile({super.key, required this.book, this.onDelete});

  final RecentBook book;
  final VoidCallback? onDelete;

  @override
  State<RecentBookCompactTile> createState() => _RecentBookCompactTileState();
}

class _RecentBookCompactTileState extends State<RecentBookCompactTile> {
  SaveFormat? _customFormat;

  SaveFormat _getEffectiveFormat(SettingsService settings) {
    return _customFormat ?? widget.book.saveFormat ?? settings.saveFormat;
  }

  Future<void> _startDownload(
    BuildContext context,
    PortalSession session,
    SaveFormat format,
  ) async {
    final deps = AppDependencies.of(context);
    final shouldProceed = await checkAndConfirmUnauthorizedDownload(
      context: context,
      session: session,
      settingsService: deps.settingsService,
    );
    if (!shouldProceed || !context.mounted) return;

    final downloadsService = deps.downloadsService;
    final task = downloadsService.getOrCreateTask(
      session: session,
      bookId: widget.book.id,
    );
    task.updateSaveFormat(format);
    if (!task.isActive) {
      task.start();
    }
    showDownloadModalForTask(context, task);
  }

  Future<void> _openDownloadedFile(
    BuildContext context,
    String filePath,
  ) async {
    HapticFeedback.lightImpact();
    final file = File(filePath);
    if (!file.existsSync()) {
      if (context.mounted) {
        overlaySnackMessage(
          context,
          'Файл книги не найден на диске (возможно, перемещён или удалён)',
        );
      }
      return;
    }
    await OpenFile.open(filePath);
  }

  Future<void> _shareBook(
    BuildContext context,
    DownloadTask? task,
    String? effectiveFilePath,
  ) async {
    HapticFeedback.lightImpact();

    if (task != null && task.savedFilePath != null && task.isCompleted) {
      await task.share();
      return;
    }

    if (effectiveFilePath != null && File(effectiveFilePath).existsSync()) {
      final fileName = p.basename(effectiveFilePath);
      final xfile = XFile(effectiveFilePath, name: fileName);
      final text =
          '«${widget.book.title}»\nАвтор: ${widget.book.authors}\nИсточник: ${widget.book.portal.name}';

      await SharePlus.instance.share(
        ShareParams(files: [xfile], text: text, subject: widget.book.title),
      );
      return;
    }

    final portalName = widget.book.portal.name;
    final text =
        '«${widget.book.title}»\nАвтор: ${widget.book.authors}\nИсточник: $portalName';
    await SharePlus.instance.share(
      ShareParams(text: text, subject: widget.book.title),
    );
  }

  String _formatDownloadedDate(DateTime date) {
    final now = DateTime.now();
    final isToday =
        now.year == date.year && now.month == date.month && now.day == date.day;
    final timeStr = DateFormat('HH:mm').format(date);
    if (isToday) return 'сегодня в $timeStr';
    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday =
        yesterday.year == date.year &&
        yesterday.month == date.month &&
        yesterday.day == date.day;
    if (isYesterday) return 'вчера в $timeStr';
    if (now.year == date.year) {
      return DateFormat('d MMM, HH:mm', 'ru').format(date);
    }
    return DateFormat('d MMM yyyy', 'ru').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final deps = AppDependencies.of(context);
    final downloadsService = deps.downloadsService;
    final settingsService = deps.settingsService;

    final session = settingsService.sessionByCode(widget.book.portal.code);
    final taskKey = DownloadsServiceBase.taskKey(
      widget.book.portal.code,
      widget.book.id,
    );

    return Observer(
      builder: (context) {
        final task = downloadsService.tasks[taskKey];
        final isDownloading = task?.isActive ?? false;
        final isCompleted = task?.isCompleted ?? false;
        final effectiveFilePath =
            task?.savedFilePath ?? widget.book.savedFilePath;
        final fileExists =
            effectiveFilePath != null && File(effectiveFilePath).existsSync();
        final effectiveFormat = _getEffectiveFormat(settingsService);
        final downloadedAt =
            (task != null && isCompleted && task.savedFilePath != null)
            ? DateTime.now()
            : widget.book.downloadedAt;

        double? progress;
        if (isDownloading && task != null) {
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
              color: isDownloading
                  ? cs.primary.withValues(alpha: 0.45)
                  : cs.outlineVariant.withValues(alpha: 0.35),
              width: isDownloading ? 1.2 : 0.6,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Book Cover (46 x 66)
                _buildCover(context, cs),
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
                          // Portal Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(AppRadii.xs),
                            ),
                            child: Text(
                              widget.book.portal.name,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ),

                          // Download status
                          if (downloadedAt != null && fileExists)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: cs.primaryContainer.withValues(
                                  alpha: 0.6,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppRadii.xs,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 11,
                                    color: cs.onPrimaryContainer,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    _formatDownloadedDate(downloadedAt),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: cs.onPrimaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (isDownloading)
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
                if (isDownloading) ...[
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
                      _startDownload(context, session, effectiveFormat);
                    },
                  ),

                  // More popup menu
                  _buildMoreMenu(
                    context,
                    cs,
                    task,
                    effectiveFilePath,
                    fileExists,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCover(BuildContext context, ColorScheme cs) {
    const width = 46.0;
    const height = 66.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: widget.book.coverUrl != null
          ? CachedNetworkImage(
              imageUrl: widget.book.coverUrl!,
              width: width,
              height: height,
              fit: BoxFit.cover,
              placeholder: (context, url) => ShimmerEffect(
                Container(
                  width: width,
                  height: height,
                  color: cs.surfaceContainerHighest,
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: width,
                height: height,
                color: cs.surfaceContainerHighest,
                child: Icon(
                  Icons.broken_image_rounded,
                  size: 20,
                  color: cs.onSurfaceVariant,
                ),
              ),
            )
          : Container(
              width: width,
              height: height,
              color: cs.surfaceContainerHighest,
              child: Icon(
                Icons.book_rounded,
                size: 20,
                color: cs.onSurfaceVariant,
              ),
            ),
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
              if (task != null &&
                  task.isCompleted &&
                  task.savedFilePath != null) {
                task.open();
              } else if (effectiveFilePath != null) {
                _openDownloadedFile(context, effectiveFilePath);
              }
            } else if (action == 'share') {
              _shareBook(context, task, effectiveFilePath);
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
