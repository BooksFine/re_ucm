import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../core/di.dart';
import '../application/recent_books_service.dart';
import 'animated_recent_book_card.dart';

class RecentBooksList extends StatefulWidget {
  const RecentBooksList({super.key});

  @override
  State<RecentBooksList> createState() => _RecentBooksListState();
}

class _RecentBooksListState extends State<RecentBooksList> {
  late final RecentBooksService service;

  @override
  void initState() {
    service = AppDependencies.of(context).recentBooksService;
    service.fetchRecentBooks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 118),
      child: Observer(
        builder: (_) {
          return AnimatedSwitcher(
            duration: Durations.medium2,
            child: () {
              if (service.recentBooks.isEmpty) {
                return Center(child: Text('Тут ничего нет :/'));
              }

              return Column(
                children: List.generate(service.recentBooks.length, (index) {
                  final i = service.recentBooks.length - index - 1;
                  return AnimatedRecentBookCard(
                    key: ValueKey(service.recentBooks[i]),
                    book: service.recentBooks[i],
                    onDelete: service.removeRecentBook,
                    isFirst: index == 0,
                  );
                }),
              );
            }(),
          );
        },
      ),
    );
  }
}
