import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../core/di.dart';
import '../../../core/ui/tokens.dart';
import '../../common/widgets/book_cover_image.dart';
import '../domain/recent_book_item_state.dart';
import 'recent_book_actions.dart';
import 'recent_book_badges.dart';
import 'recent_book_controls.dart';
import 'recent_book_more_menu.dart';
import 'recent_book_shared.dart';
import 'recent_book_utils.dart';

class RecentBookCompactTile extends StatelessWidget {
  const RecentBookCompactTile({super.key, required this.book, this.onDelete});

  final RecentBook book;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= AppBreakpoints.wideCards;

    final deps = AppDependencies.of(context);
    final session = deps.settingsService.sessionByCode(book.portal.code);
    return Observer(
      builder: (context) {
        final state = RecentBookItemState.resolve(
          book,
          deps.downloadsService,
        );
        final effectiveFormat = getEffectiveFormat(book, deps.settingsService);
        final task = state.task;
        final seriesLine = formatSeriesLine(book);
        return RecentBookContainer(
          isDownloading: state.isDownloading,
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BookCoverImage(
                coverUrl: book.coverUrl,
                width: 46,
                height: 66,
                iconSize: 20,
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      book.title,
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
                      seriesLine != null
                          ? '${book.authors} • $seriesLine'
                          : book.authors,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    RecentBookBadgesRow(
                      book: book,
                      state: state,
                      showDownloadProgress: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (state.isDownloading)
                RecentBookDownloadingRow(task: task, compact: true)
              else ...[
                DownloadButton(
                  iconOnly: !isWide,
                  size: M3EButtonSize.xs,
                  onPressed: () {
                    startDownload(
                      context,
                      session,
                      effectiveFormat,
                      book.id,
                    );
                  },
                ),
                RecentBookMoreMenu(
                  book: book,
                  task: task,
                  effectiveFilePath: state.effectiveFilePath,
                  fileExists: state.fileExists,
                  showOpen: true,
                  showShare: true,
                  onDelete: onDelete,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
