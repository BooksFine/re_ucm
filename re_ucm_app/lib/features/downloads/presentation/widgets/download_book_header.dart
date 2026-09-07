import 'package:dart_book/dart_book.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/re_ucm_core.dart';

import '../../../../core/ui/tokens.dart';
import '../../../common/widgets/book_cover_image.dart';
import '../../../common/widgets/shimmer.dart';

class DownloadBookHeader extends StatelessWidget {
  const DownloadBookHeader({
    super.key,
    required this.book,
    required this.portal,
    this.isWide = false,
  });

  final BookMetadata book;
  final Portal portal;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final coverUrl = book.cover?.ref.id;
    final authors = book.authorsDisplay;

    final (coverWidth, coverHeight) = _coverDimensions(isWide);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cover — единый виджет (был скопирован в header/list/live).
        BookCoverImage(
          coverUrl: (coverUrl != null && coverUrl.isNotEmpty) ? coverUrl : null,
          width: coverWidth,
          height: coverHeight,
          iconSize: coverWidth * 0.4,
          errorIcon: Icons.book_rounded,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),

        const SizedBox(width: AppSpacing.lg),

        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Portal badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Text(
                  portal.name,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Title
              Text(
                book.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Authors
              Text(
                authors.isNotEmpty ? authors : 'Автор не указан',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // Series and / or text length
              if (book.primarySeries != null || book.textLength != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (book.primarySeries != null)
                      Flexible(
                        child: Text(
                          '${book.primarySeries!.name} #${book.primarySeries!.number ?? 1}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (book.primarySeries != null && book.textLength != null)
                      Text(
                        ' • ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    if (book.textLength != null)
                      Text(
                        '${formatGrouped(book.textLength!)} зн.',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.8,
                          ),
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class DownloadBookHeaderSkeleton extends StatelessWidget {
  const DownloadBookHeaderSkeleton({super.key, this.isWide = false});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final (coverWidth, coverHeight) = _coverDimensions(isWide);

    return ShimmerEffect(
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: coverWidth,
            height: coverHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.md),
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 55,
                  height: 16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 18,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.xs),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 130,
                  height: 14,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.xs),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 85,
                  height: 12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.xs),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

(double width, double height) _coverDimensions(bool isWide) =>
    isWide ? (85.0, 122.0) : (72.0, 104.0);



