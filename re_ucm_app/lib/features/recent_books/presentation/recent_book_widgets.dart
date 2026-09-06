import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/re_ucm_core.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import 'recent_book_shared.dart';

/// Совместимые шимы: новым кодом использовать [PortalBadge],
/// [DownloadedBadge] и [BookCoverImage] напрямую.
Widget buildPortalBadge(BuildContext context, Portal portal) =>
    PortalBadge(portal: portal);

Widget? buildDownloadedBadge(
  BuildContext context, {
  required DateTime? downloadedAt,
  required bool isVisible,
  String? prefix,
}) {
  if (downloadedAt == null || !isVisible) return null;
  return DownloadedBadge(downloadedAt: downloadedAt, prefix: prefix);
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
  return BookCoverImage(
    coverUrl: book.coverUrl,
    width: width,
    height: height,
    iconSize: iconSize,
    borderRadius: borderRadius,
  );
}
