import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/ui/tokens.dart';
import 'shimmer.dart';

/// Единая обложка с кэшем/шиммером/фолбэком.
///
/// Каноническое место жизни класса. Работает по coverUrl —
/// переиспользуется в recent_books и downloads (header/list/live).
/// В `features/recent_books/presentation/recent_book_shared.dart`
/// оставлен deprecated-наследник ради чужих импортов.
class BookCoverImage extends StatelessWidget {
  const BookCoverImage({
    super.key,
    required this.coverUrl,
    required this.width,
    required this.height,
    this.iconSize = 24,
    this.errorIcon = Icons.broken_image_rounded,
    this.placeholderIcon = Icons.book_rounded,
    this.borderRadius = const BorderRadius.all(Radius.circular(AppRadii.md)),
  });

  final String? coverUrl;
  final double width;
  final double height;
  final double iconSize;
  final IconData errorIcon;
  final IconData placeholderIcon;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final url = coverUrl;
    return ClipRRect(
      borderRadius: borderRadius,
      child: url != null
          ? CachedNetworkImage(
              imageUrl: url,
              width: width,
              height: height,
              fit: BoxFit.cover,
              placeholder: (context, url) => ShimmerEffect(
                Container(
                  width: width,
                  height: height,
                  color: cs.surfaceContainerHighest,
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: width,
                height: height,
                color: cs.surfaceContainerHighest,
                child: Icon(
                  errorIcon,
                  size: iconSize,
                  color: cs.onSurfaceVariant,
                ),
              ),
            )
          : Container(
              width: width,
              height: height,
              color: cs.surfaceContainerHighest,
              child: Icon(
                placeholderIcon,
                size: iconSize,
                color: cs.onSurfaceVariant,
              ),
            ),
    );
  }
}
