import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/re_ucm_core.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../core/ui/tokens.dart';
import '../../../core/ui/widgets/portal_badge.dart';
import '../domain/recent_book_item_state.dart';
import 'recent_book_utils.dart';

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

class RecentBookBadgesRow extends StatelessWidget {
  const RecentBookBadgesRow({
    super.key,
    required this.book,
    required this.state,
    this.downloadedPrefix,
    this.showDownloadProgress = false,
  });

  final RecentBook book;
  final RecentBookItemState state;
  final String? downloadedPrefix;
  final bool showDownloadProgress;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        PortalBadge(portal: book.portal),
        if (state.fileExists)
          DownloadedBadge(
            downloadedAt: state.downloadedAt,
            prefix: downloadedPrefix,
          )
        else if (showDownloadProgress && state.isDownloading)
          _buildDownloadProgress(context),
      ],
    );
  }

  Widget _buildDownloadProgress(BuildContext context) {
    final pct = state.task?.progress.normalized;
    final theme = Theme.of(context);
    return Text(
      pct != null ? 'Загрузка ${(pct * 100).toInt()}%' : 'Загрузка...',
      style: theme.textTheme.labelSmall?.copyWith(
        fontSize: 10,
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
