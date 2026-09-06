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
import 'package:text_balancer/text_balancer.dart';

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

    // 1. If active task is completed and has its own share routine with chapters info
    if (task != null && task.savedFilePath != null && task.isCompleted) {
      await task.share();
      return;
    }

    // 2. If we have a stored file on disk from recent book or task
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

    // 3. Fallback: Share book details and portal info
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
    if (isToday) {
      return 'сегодня в $timeStr';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday =
        yesterday.year == date.year &&
        yesterday.month == date.month &&
        yesterday.day == date.day;
    if (isYesterday) {
      return 'вчера в $timeStr';
    }
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
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(
              color: isDownloading
                  ? cs.primary.withValues(alpha: 0.4)
                  : cs.outlineVariant.withValues(alpha: 0.35),
              width: isDownloading ? 1.2 : 0.6,
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
                  _buildCover(context, cs),
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
                              onPressed: () =>
                                  _shareBook(context, task, effectiveFilePath),
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
                            // Portal Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(
                                  AppRadii.xs,
                                ),
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

                            // Downloaded date badge if downloaded
                            if (downloadedAt != null && fileExists) ...[
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
                                      'Скачано ${_formatDownloadedDate(downloadedAt)}',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: cs.onPrimaryContainer,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Bottom Actions: Read file button (if available) and Split Download Button
                        Builder(
                          builder: (context) {
                            final isCompact = fileExists || !widget.isWide;

                            return Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: AppSpacing.xs,
                              runSpacing: AppSpacing.xs,
                              children: [
                                // "Open / Read" button if downloaded and file exists
                                if (fileExists)
                                  M3EButton.icon(
                                    style: M3EButtonStyle.tonal,
                                    size: M3EButtonSize.sm,
                                    shape: M3EButtonShape.round,
                                    icon: const Icon(Icons.menu_book_rounded),
                                    label: const Text('Читать'),
                                    onPressed: () {
                                      if (task != null &&
                                          task.isCompleted &&
                                          task.savedFilePath != null) {
                                        task.open();
                                      } else {
                                        _openDownloadedFile(
                                          context,
                                          effectiveFilePath,
                                        );
                                      }
                                    },
                                  ),

                                // Primary Action: M3E Split Button for download & format
                                M3EButton.icon(
                                  style: M3EButtonStyle.tonal,
                                  size: M3EButtonSize.sm,
                                  shape: M3EButtonShape.round,
                                  icon: const Icon(Icons.download_rounded),
                                  label: const Text('Скачать'),
                                  onPressed: () {
                                    _startDownload(
                                      context,
                                      session,
                                      effectiveFormat,
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

  Widget _buildCover(BuildContext context, ColorScheme cs) {
    const width = 68.0;
    const height = 98.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.md),
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
                  color: cs.onSurfaceVariant,
                ),
              ),
            )
          : Container(
              width: width,
              height: height,
              color: cs.surfaceContainerHighest,
              child: Icon(Icons.book_rounded, color: cs.onSurfaceVariant),
            ),
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
