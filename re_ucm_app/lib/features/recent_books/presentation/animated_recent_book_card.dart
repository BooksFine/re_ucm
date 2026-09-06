import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../core/ui/tokens.dart';
import 'recent_book_card.dart';
import 'recent_book_compact_tile.dart';

class AnimatedRecentBookCard extends StatefulWidget {
  const AnimatedRecentBookCard({
    super.key,
    required this.book,
    required this.onDelete,
    required this.isFirst,
    this.viewMode = RecentBooksViewMode.compact,
  });
  final RecentBook book;
  final bool isFirst;
  final RecentBooksViewMode viewMode;
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
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> deleteBook() async {
    await _controller.reverse();
    onDismissed();
  }

  Future<void> onDismissed() async {
    widget.onDelete(widget.book);
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(widget.book),
      onDismissed: (_) => onDismissed(),
      child: SizeTransition(
        sizeFactor: _sizeAnimation,
        axis: .vertical,
        alignment: .topCenter,
        child: Padding(
          padding: .only(top: widget.isFirst ? 0 : (widget.viewMode == RecentBooksViewMode.compact ? 2 : AppSpacing.sm)),
          child: widget.viewMode == RecentBooksViewMode.compact
              ? RecentBookCompactTile(
                  onDelete: deleteBook,
                  book: widget.book,
                )
              : RecentBookCard(
                  onDelete: deleteBook,
                  book: widget.book,
                ),
        ),
      ),
    );
  }
}
