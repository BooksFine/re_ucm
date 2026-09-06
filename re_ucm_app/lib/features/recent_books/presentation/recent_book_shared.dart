import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/re_ucm_core.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../core/di.dart';
import '../../../core/navigation/router_delegate.dart';
import '../../../core/ui/tokens.dart';
import '../../../core/ui/widgets/m3e_spring_popup.dart';
import '../../common/widgets/shimmer.dart';
import '../../downloads/domain/download_task.cg.dart';
import 'recent_book_actions.dart';
import 'recent_book_utils.dart';

/// Выносит дословный пролог card/tile (~20 строк):
/// deps → session → Observer(state/format).
class RecentBookScope extends StatelessWidget {
  const RecentBookScope({
    super.key,
    required this.book,
    required this.builder,
  });

  final RecentBook book;
  final Widget Function(
    BuildContext context,
    RecentBookItemState state,
    PortalSession session,
    SaveFormat effectiveFormat,
  )
  builder;

  @override
  Widget build(BuildContext context) {
    final deps = AppDependencies.of(context);
    final session = deps.settingsService.sessionByCode(book.portal.code);
    return Observer(
      builder: (context) {
        final state = RecentBookItemState.resolve(
          book,
          deps.downloadsService,
        );
        final format = getEffectiveFormat(book, deps.settingsService);
        return builder(context, state, session, format);
      },
    );
  }
}

/// Единый контейнер карточки списка. Убирает дрейф
/// `alpha 0.4 vs 0.45` между card и tile.
class RecentBookContainer extends StatelessWidget {
  const RecentBookContainer({
    super.key,
    required this.isDownloading,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin = const EdgeInsets.symmetric(vertical: 4),
  });

  final bool isDownloading;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: margin,
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
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class PortalBadge extends StatelessWidget {
  const PortalBadge({super.key, required this.portal});

  final Portal portal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.xs),
      ),
      child: Text(
        portal.name,
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

class DownloadedBadge extends StatelessWidget {
  const DownloadedBadge({
    super.key,
    required this.downloadedAt,
    this.prefix,
  });

  final DateTime? downloadedAt;
  final String? prefix;

  @override
  Widget build(BuildContext context) {
    if (downloadedAt == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final text = prefix != null
        ? '$prefix ${formatDownloadedDate(downloadedAt!)}'
        : formatDownloadedDate(downloadedAt!);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadii.xs),
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
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: cs.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

/// Единая обложка с кэшем/шиммером/фолбэком.
/// Работает по coverUrl — переиспользуется и в downloads
/// (header/list/live), где раньше ветка была скопирована трижды.
class BookCoverImage extends StatelessWidget {
  const BookCoverImage({
    super.key,
    required this.coverUrl,
    required this.width,
    required this.height,
    this.iconSize = 24,
    this.errorIcon = Icons.broken_image_rounded,
    this.placeholderIcon = Icons.book_rounded,
    this.borderRadius = const BorderRadius.all(Radius.circular(AppRadii.md)),
  });

  final String? coverUrl;
  final double width;
  final double height;
  final double iconSize;
  final IconData errorIcon;
  final IconData placeholderIcon;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final url = coverUrl;
    return ClipRRect(
      borderRadius: borderRadius,
      child: url != null
          ? CachedNetworkImage(
              imageUrl: url,
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
                  errorIcon,
                  size: iconSize,
                  color: cs.onSurfaceVariant,
                ),
              ),
            )
          : Container(
              width: width,
              height: height,
              color: cs.surfaceContainerHighest,
              child: Icon(
                placeholderIcon,
                size: iconSize,
                color: cs.onSurfaceVariant,
              ),
            ),
    );
  }
}

/// Строка прогресса загрузки + отмена. Раньше жила только в tile —
/// в full-card при скачивании была лишь рамка без % и отмены.
class RecentBookDownloadingRow extends StatelessWidget {
  const RecentBookDownloadingRow({
    super.key,
    required this.task,
    this.compact = false,
  });

  final DownloadTask? task;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final progress = task?.progress.normalized;
    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () => task?.cancel(),
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: Text(
            progress != null
                ? 'Загрузка ${(progress * 100).toInt()}%'
                : 'Загрузка...',
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 10,
              color: cs.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Отменить',
          icon: const Icon(Icons.close_rounded, size: 18),
          visualDensity: VisualDensity.compact,
          onPressed: () => task?.cancel(),
        ),
      ],
    );
  }
}

/// Кнопка «Читать». Заменяет флаг `iconOnlyRead` в `_buildActions`:
/// компактный вариант — без подписи, расширенный — с подписью.
class ReadButton extends StatelessWidget {
  const ReadButton({
    super.key,
    required this.task,
    required this.effectiveFilePath,
    this.label,
  });

  final DownloadTask? task;
  final String? effectiveFilePath;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final label = this.label;
    if (label == null) {
      return Tooltip(
        message: 'Читать',
        child: M3EButton(
          style: M3EButtonStyle.tonal,
          size: M3EButtonSize.sm,
          shape: M3EButtonShape.round,
          onPressed: () => openBook(
            context,
            task: task,
            effectiveFilePath: effectiveFilePath,
          ),
          child: const Icon(Icons.menu_book_rounded),
        ),
      );
    }
    return M3EButton.icon(
      style: M3EButtonStyle.tonal,
      size: M3EButtonSize.sm,
      shape: M3EButtonShape.round,
      icon: const Icon(Icons.menu_book_rounded),
      label: Text(label),
      onPressed: () => openBook(
        context,
        task: task,
        effectiveFilePath: effectiveFilePath,
      ),
    );
  }
}

/// Единое «⋮»-меню. Card показывает browser/delete, tile —
/// open/share/browser/delete: разница только набором пунктов.
class RecentBookMoreMenu extends StatelessWidget {
  const RecentBookMoreMenu({
    super.key,
    required this.book,
    required this.task,
    required this.effectiveFilePath,
    required this.fileExists,
    this.showOpen = false,
    this.showShare = false,
    this.onDelete,
  });

  final RecentBook book;
  final DownloadTask? task;
  final String? effectiveFilePath;
  final bool fileExists;
  final bool showOpen;
  final bool showShare;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
              items: [
                if (showOpen && fileExists)
                  const M3ESpringPopupItem<String>(
                    value: 'open',
                    label: 'Читать',
                    icon: Icons.menu_book_rounded,
                  ),
                if (showShare)
                  const M3ESpringPopupItem<String>(
                    value: 'share',
                    label: 'Поделиться',
                    icon: Icons.share_outlined,
                  ),
                const M3ESpringPopupItem<String>(
                  value: 'browser',
                  label: 'Открыть в браузере',
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
            if (!btnContext.mounted) return;
            switch (action) {
              case 'open':
                await openBook(
                  btnContext,
                  task: task,
                  effectiveFilePath: effectiveFilePath,
                );
              case 'share':
                if (btnContext.mounted) {
                  shareBook(btnContext, task, effectiveFilePath, book);
                }
              case 'browser':
                Nav.goBrowser(book.portal.code);
              case 'delete':
                onDelete?.call();
            }
          },
        );
      },
    );
  }
}
