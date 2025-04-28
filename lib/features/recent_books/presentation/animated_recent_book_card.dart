import 'package:flutter/material.dart';
import 'package:re_ucm_core/ui/constants.dart';
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

  void deleteBook() async {
    await _controller.reverse();
    widget.onDelete(widget.book);
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _sizeAnimation,
      axis: Axis.vertical,
      axisAlignment: 0.0,
      child: Dismissible(
        key: ValueKey(widget.book),
        onDismissed: (direction) {
          widget.onDelete(widget.book);
        },
        child: Padding(
          padding: EdgeInsets.only(top: widget.isFirst ? 0 : appPadding),
          child: RecentBookCard(onDelete: deleteBook, book: widget.book),
        ),
      ),
    );
  }
}
