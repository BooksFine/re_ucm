import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';
import 'package:text_balancer/text_balancer.dart';

import '../../../core/ui/tokens.dart';
import '../../common/widgets/book_cover_image.dart';
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
          isDownloading: presenter.isDownloading,
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
                  presenter: presenter,
                  isWide: isWide,
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

class _CardInfo extends StatelessWidget {
  const _CardInfo({
    required this.book,
    required this.presenter,
    required this.isWide,
    required this.onDelete,
  });

  final RecentBook book;
  final RecentBookPresenter presenter;
  final bool isWide;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final topActions = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (presenter.fileExists)
          IconButton(
            tooltip: 'Поделиться',
            icon: Icon(Icons.share_outlined, size: 20, color: cs.onSurfaceVariant),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            onPressed: () => shareBook(
              context,
              presenter.task,
              presenter.effectiveFilePath,
              book,
            ),
          ),
        RecentBookMoreMenu(
          book: book,
          task: presenter.task,
          effectiveFilePath: presenter.effectiveFilePath,
          fileExists: presenter.fileExists,
          onDelete: onDelete,
        ),
      ],
    );

    final badges = RecentBookBadgesRow(
      book: book,
      state: presenter.state,
      downloadedPrefix: 'Скачано',
    );

    final downloadActions = presenter.isDownloading
        ? RecentBookDownloadingRow(task: presenter.task)
        : Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (presenter.fileExists)
                ReadButton(
                  task: presenter.task,
                  effectiveFilePath: presenter.effectiveFilePath,
                  label: 'Читать',
                ),
              DownloadButton(
                onPressed: presenter.canDownload ? presenter.onDownload : null,
              ),
            ],
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
