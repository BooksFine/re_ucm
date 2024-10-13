import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:re_ucm_core/ui/constants.dart';

import '../../../core/di.dart';
import '../application/recent_books_service.dart';
import 'recent_book_card.dart';

final _key = GlobalKey();

class RecentBooksList extends StatefulWidget {
  RecentBooksList() : super(key: _key);

  @override
  State<RecentBooksList> createState() => _RecentBooksListState();
}

class _RecentBooksListState extends State<RecentBooksList> {
  final RecentBooksService service = locator();

  @override
  void initState() {
    service.fetchRecentBooks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      if (service.recentBooks.isEmpty) {
        return const SizedBox(
          height: 100,
          child: Center(
            child: Text('Тут ничего нет :/'),
          ),
        );
      }

      return ListView.separated(
        padding: EdgeInsets.zero,
        reverse: true,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: service.recentBooks.length,
        itemBuilder: (context, index) => RecentBookCard(
          book: service.recentBooks[index],
          key: ValueKey(service.recentBooks[index]),
        ),
        separatorBuilder: (context, index) =>
            const SizedBox(height: appPadding),
      );
    });
  }
}
