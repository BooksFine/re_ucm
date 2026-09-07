import 'package:flutter/widgets.dart';

import '../recent_books_list.dart';
import 'recent_books_header.dart';

/// Reusable sliver bundle for the Recent Books section (header + list).
List<Widget> buildRecentBooksSlivers({
  EdgeInsetsGeometry headerPadding = EdgeInsets.zero,
  EdgeInsetsGeometry listPadding = EdgeInsets.zero,
  EdgeInsetsGeometry headerInnerPadding = EdgeInsets.zero,
}) {
  return [
    SliverPadding(
      padding: headerPadding,
      sliver: SliverToBoxAdapter(
        child: RecentBooksHeader(padding: headerInnerPadding),
      ),
    ),
    SliverPadding(
      padding: listPadding,
      sliver: const SliverToBoxAdapter(
        child: RecentBooksList(),
      ),
    ),
  ];
}
