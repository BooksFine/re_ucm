import 'dart:math';

import 'package:flutter/material.dart';
import 'package:text_balancer/text_balancer.dart';

import '../../../core/di.dart';
import '../../../core/ui/constants.dart';
import '../application/recent_books_service.dart';
import '../domain/recent_book.cg.dart';
import 'recent_book_card.dart';

class AnimatedRecentBookCard extends StatefulWidget {
  const AnimatedRecentBookCard({
    super.key,
    required this.book,
    required this.onDelete,
    required this.isFirst,
  });
  final RecentBook book;
  final bool isFirst;
  final Function(RecentBook book) onDelete;

  @override
  State<AnimatedRecentBookCard> createState() => _AnimatedRecentBookCardState();
}

class _AnimatedRecentBookCardState extends State<AnimatedRecentBookCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late RecentBooksService _service;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Durations.medium2, vsync: this);
    _sizeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    _service = AppDependencies.of(context).recentBooksService;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void showUndoSnackBar(ScaffoldMessengerState messenger) {
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        width: min(500, MediaQuery.sizeOf(context).width - 32),
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.horizontal,
        duration: const Duration(seconds: 3),
        content: TextBalancer('Удалено «${widget.book.title}»'),
        action: SnackBarAction(
          label: 'Отменить',
          onPressed: () => _service.restoreRecentBook(widget.book),
        ),
      ),
    );
  }

  Future<void> deleteBook() async {
    await _controller.reverse();
    onDismissed();
  }

  Future<void> onDismissed() async {
    final messenger = ScaffoldMessenger.of(context);
    widget.onDelete(widget.book);
    showUndoSnackBar(messenger);
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(widget.book),
      onDismissed: (_) => onDismissed(),
      child: SizeTransition(
        sizeFactor: _sizeAnimation,
        axis: .vertical,
        alignment: .center,
        child: Padding(
          padding: .only(top: widget.isFirst ? 0 : appPadding),
          child: RecentBookCard(onDelete: deleteBook, book: widget.book),
        ),
      ),
    );
  }
}
