import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/re_ucm_core.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../core/ui/tokens.dart';
import '../../common/widgets/shimmer.dart';
import 'recent_book_utils.dart';

Widget buildPortalBadge(BuildContext context, Portal portal) {
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

Widget? buildDownloadedBadge(
  BuildContext context, {
  required DateTime? downloadedAt,
  required bool isVisible,
  String? prefix,
}) {
  if (downloadedAt == null || !isVisible) return null;
  final theme = Theme.of(context);
  final cs = theme.colorScheme;
  final text = prefix != null
      ? '$prefix ${formatDownloadedDate(downloadedAt)}'
      : formatDownloadedDate(downloadedAt);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: cs.primaryContainer.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(AppRadii.xs),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle_rounded, size: 11, color: cs.onPrimaryContainer),
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

Widget buildCover(
  BuildContext context,
  ColorScheme cs,
  RecentBook book, {
  required double width,
  required double height,
  double iconSize = 24,
  required BorderRadius borderRadius,
}) {
  return ClipRRect(
    borderRadius: borderRadius,
    child: book.coverUrl != null
        ? CachedNetworkImage(
            imageUrl: book.coverUrl!,
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
              Icons.book_rounded,
              size: iconSize,
              color: cs.onSurfaceVariant,
            ),
          ),
  );
}
