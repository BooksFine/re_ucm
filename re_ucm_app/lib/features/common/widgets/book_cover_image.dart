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

  Widget _buildPlaceholder(ColorScheme cs, {IconData? icon}) {
    return Container(
      width: width,
      height: height,
      color: cs.surfaceContainerHighest,
      child: icon != null
          ? Icon(
              icon,
              size: iconSize,
              color: cs.onSurfaceVariant,
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final url = coverUrl?.trim();
    final hasValidUrl = url != null && url.isNotEmpty;

    return ClipRRect(
      borderRadius: borderRadius,
      child: hasValidUrl
          ? CachedNetworkImage(
              imageUrl: url,
              width: width,
              height: height,
              fit: BoxFit.cover,
              placeholder: (context, url) => ShimmerEffect(
                _buildPlaceholder(cs),
              ),
              errorWidget: (context, url, error) => _buildPlaceholder(
                cs,
                icon: errorIcon,
              ),
            )
          : _buildPlaceholder(
              cs,
              icon: placeholderIcon,
            ),
    );
  }
}
