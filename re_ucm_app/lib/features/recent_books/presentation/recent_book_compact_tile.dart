import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/re_ucm_core.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../core/ui/tokens.dart';
import 'recent_book_actions.dart';
import 'recent_book_shared.dart';

class RecentBookCompactTile extends StatelessWidget {
  const RecentBookCompactTile({super.key, required this.book, this.onDelete});

  final RecentBook book;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= AppBreakpoints.wideCards;

    return RecentBookScope(
      book: book,
      builder: (context, state, session, effectiveFormat) {
        final task = state.task;
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
                      book.seriesName != null
                          ? '${book.authors} • ${book.seriesName!} #${book.seriesNumber ?? 1}'
                          : book.authors,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        PortalBadge(portal: book.portal),
                        if (state.fileExists)
                          DownloadedBadge(
                            downloadedAt: state.downloadedAt,
                          )
                        else if (state.isDownloading)
                          Builder(
                            builder: (_) {
                              final pct = task?.progress.normalized;
                              return Text(
                                pct != null
                                    ? 'Загрузка ${(pct * 100).toInt()}%'
                                    : 'Загрузка...',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (state.isDownloading)
                RecentBookDownloadingRow(task: task, compact: true)
              else ...[
                if (isWide)
                  M3EButton.icon(
                    style: M3EButtonStyle.tonal,
                    size: M3EButtonSize.xs,
                    shape: M3EButtonShape.round,
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Скачать'),
                    onPressed: () {
                      startDownload(
                        context,
                        session,
                        effectiveFormat,
                        book.id,
                      );
                    },
                  )
                else
                  M3EButton(
                    style: M3EButtonStyle.tonal,
                    size: M3EButtonSize.xs,
                    shape: M3EButtonShape.round,
                    onPressed: () {
                      startDownload(
                        context,
                        session,
                        effectiveFormat,
                        book.id,
                      );
                    },
                    child: const Icon(Icons.download_rounded),
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
