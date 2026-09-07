import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';
import 'package:text_balancer/text_balancer.dart';

import '../../../core/ui/tokens.dart';
import '../../common/widgets/book_cover_image.dart';
import '../domain/recent_book_item_state.dart';
import 'recent_book_actions.dart';
import 'recent_book_badges.dart';
import 'recent_book_controls.dart';
import 'recent_book_more_menu.dart';
import 'recent_book_shared.dart';

class RecentBookCard extends StatelessWidget {
  const RecentBookCard({super.key, required this.book, this.onDelete});

  final RecentBook book;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= AppBreakpoints.wideCards;

    return Observer(
      builder: (context) {
        final presenter = RecentBookPresenter.resolve(context, book);

        return RecentBookContainer(
          isDownloading: presenter.state.isDownloading,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookCoverImage(
                coverUrl: book.coverUrl,
                width: 68,
                height: 98,
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _CardInfo(
                  book: book,
                  state: presenter.state,
                  session: presenter.session,
                  effectiveFormat: presenter.effectiveFormat,
                  isWide: isWide,
                  onDownload: presenter.onDownload,
                  onDelete: onDelete,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.book});

  final RecentBook book;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final seriesLine = formatSeriesLine(book);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextBalancer(
          book.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          book.authors,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
            fontSize: 13,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (seriesLine != null) ...[
          const SizedBox(height: 3),
          Text(
            seriesLine,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 6),
      ],
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({
    required this.book,
    required this.state,
  });

  final RecentBook book;
  final RecentBookItemState state;

  @override
  Widget build(BuildContext context) {
    if (!state.fileExists) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: 'Поделиться',
      icon: Icon(Icons.share_outlined, size: 20, color: cs.onSurfaceVariant),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      onPressed: () => shareBook(
        context,
        state.task,
        state.effectiveFilePath,
        book,
      ),
    );
  }
}

class _DownloadActions extends StatelessWidget {
  const _DownloadActions({
    required this.state,
    required this.session,
    required this.onDownload,
    this.readLabel,
  });

  final RecentBookItemState state;
  final PortalSession? session;
  final VoidCallback onDownload;
  final String? readLabel;

  @override
  Widget build(BuildContext context) {
    if (state.isDownloading) {
      return RecentBookDownloadingRow(task: state.task);
    }
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (state.fileExists)
          ReadButton(
            task: state.task,
            effectiveFilePath: state.effectiveFilePath,
            label: readLabel,
          ),
        DownloadButton(
          onPressed: session == null ? null : onDownload,
        ),
      ],
    );
  }
}

class _CardInfo extends StatelessWidget {
  const _CardInfo({
    required this.book,
    required this.state,
    required this.session,
    required this.effectiveFormat,
    required this.isWide,
    required this.onDownload,
    required this.onDelete,
  });

  final RecentBook book;
  final RecentBookItemState state;
  final PortalSession? session;
  final SaveFormat effectiveFormat;
  final bool isWide;
  final VoidCallback onDownload;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final topActions = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        _ShareButton(book: book, state: state),
        RecentBookMoreMenu(
          book: book,
          task: state.task,
          effectiveFilePath: state.effectiveFilePath,
          fileExists: state.fileExists,
          onDelete: onDelete,
        ),
      ],
    );

    final badges = RecentBookBadgesRow(
      book: book,
      state: state,
      downloadedPrefix: 'Скачано',
    );

    final downloadActions = _DownloadActions(
      state: state,
      session: session,
      onDownload: onDownload,
      readLabel: 'Читать',
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TitleBlock(book: book),
                badges,
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              topActions,
              const SizedBox(height: 6),
              downloadActions,
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _TitleBlock(book: book)),
            const SizedBox(width: AppSpacing.sm),
            topActions,
          ],
        ),
        badges,
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: downloadActions,
        ),
      ],
    );
  }
}
