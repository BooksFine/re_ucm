import 'package:material_ui/material_ui.dart';

import '../../recent_books/presentation/recent_books_list.dart';
import '../../recent_books/presentation/widgets/recent_books_header.dart';

/// Общая секция «Последние книги»: заголовок + список + нижний отступ.
/// Убирает копипаст между portrait/landscape — поведение то же,
/// отличаются только паддинги, которые передаются параметрами.
class RecentBooksSection extends StatelessWidget {
  const RecentBooksSection({
    super.key,
    required this.headerOuterPadding,
    this.headerInnerPadding = EdgeInsets.zero,
    this.listPadding,
    this.bottomSpacing = 0,
  });

  /// Внешний отступ вокруг заголовка.
  final EdgeInsetsGeometry headerOuterPadding;

  /// Внутренний отступ самого [RecentBooksHeader].
  final EdgeInsetsGeometry headerInnerPadding;

  /// Если задан — список оборачивается в [SliverPadding] с ним
  /// (portrait). Если null — список без обёртки (landscape).
  final EdgeInsetsGeometry? listPadding;

  /// Дополнительный отступ после списка (landscape bottomInset).
  final double bottomSpacing;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: headerOuterPadding,
            child: RecentBooksHeader(padding: headerInnerPadding),
          ),
        ),
        if (listPadding != null)
          SliverPadding(
            padding: listPadding!,
            sliver: const SliverToBoxAdapter(child: RecentBooksList()),
          )
        else
          const SliverToBoxAdapter(child: RecentBooksList()),
        if (bottomSpacing > 0)
          SliverToBoxAdapter(child: SizedBox(height: bottomSpacing)),
      ],
    );
  }
}
