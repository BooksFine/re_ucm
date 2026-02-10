import 'dart:math';

import 'package:flutter/material.dart';
import 'package:re_ucm_core/ui/constants.dart';
import 'package:text_balancer/text_balancer.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Durations.medium2, vsync: this);
    _sizeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> isDeleteConfirmed() async {
    bool isConfirmed = true;

    final snack = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        width: min(500, MediaQuery.sizeOf(context).width - 32),
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.horizontal,
        duration: Duration(seconds: 3),
        content: TextBalancer('Удалено «${widget.book.title}»'),
        action: SnackBarAction(
          label: 'Отменить',
          onPressed: () => isConfirmed = false,
        ),
      ),
    );

    await snack.closed;

    return isConfirmed;
  }

  bool isDismissed = false;
  onDismissed() async {
    isDismissed = true;
    setState(() {});

    if (await isDeleteConfirmed()) {
      return widget.onDelete(widget.book);
    }

    _controller.forward(from: 0);
    isDismissed = false;
    setState(() {});
  }

  deleteBook() async {
    await _controller.reverse();

    if (await isDeleteConfirmed()) {
      return widget.onDelete(widget.book);
    }

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (isDismissed) return SizedBox.shrink();

    return Dismissible(
      key: ValueKey(widget.book),
      onDismissed: (_) => onDismissed(),
      child: SizeTransition(
        sizeFactor: _sizeAnimation,
        axis: Axis.vertical,
        axisAlignment: 0.0,
        child: Padding(
          padding: EdgeInsets.only(top: widget.isFirst ? 0 : appPadding),
          child: RecentBookCard(onDelete: deleteBook, book: widget.book),
        ),
      ),
    );
  }
}
