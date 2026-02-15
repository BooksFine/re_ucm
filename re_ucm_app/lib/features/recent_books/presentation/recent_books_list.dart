import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:text_balancer/text_balancer.dart';

import '../../../core/di.dart';
import '../application/recent_books_service.dart';
import '../domain/recent_book.cg.dart';
import 'animated_recent_book_card.dart';

class RecentBooksList extends StatefulWidget {
  const RecentBooksList({super.key});

  @override
  State<RecentBooksList> createState() => _RecentBooksListState();
}

class _RecentBooksListState extends State<RecentBooksList> {
  late RecentBooksService service;

  @override
  void didChangeDependencies() {
    service = AppDependencies.of(context).recentBooksService;
    super.didChangeDependencies();
  }

  void showUndoSnackBar(RecentBook book) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        persist: false,
        width: min(500, MediaQuery.sizeOf(context).width - 32),
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.horizontal,
        duration: const Duration(seconds: 2),
        content: TextBalancer('Удалено «${book.title}»'),
        action: SnackBarAction(
          label: 'Отменить',
          onPressed: () => service.restoreRecentBook(book),
        ),
      ),
    );
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
                    onDelete: (book) {
                      showUndoSnackBar(book);
                      service.removeRecentBook(book);
                    },
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
