import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:re_ucm_core/ui/constants.dart';

import '../../../core/navigation/router_delegate.dart';
import '../../common/widgets/shimmer.dart';
import '../domain/recent_book.cg.dart';

class RecentBookCard extends StatelessWidget {
  const RecentBookCard({super.key, required this.book, this.onDelete});

  final RecentBook book;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(cardBorderRadius),
        onTap: () => Nav.book(book.portal.code, book.id),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (book.coverUrl != null)
              Padding(
                padding: const EdgeInsets.all(4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(cardBorderRadius),
                  child: CachedNetworkImage(
                    placeholder: (context, url) => ShimmerEffect(
                      Container(width: 75, height: 100, color: Colors.white),
                    ),
                    imageUrl: book.coverUrl!,
                    width: 75,
                    height: 110,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Card(
                color: Theme.of(context).colorScheme.surface,
                child: const SizedBox(
                  width: 75,
                  height: 100,
                  child: Center(child: Icon(Icons.image)),
                ),
              ),
            const SizedBox(width: appPadding),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: appPadding),
                  Text(
                    book.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    book.authors,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  if (book.seriesName != null)
                    Text(
                      '${book.seriesName!} #${book.seriesNumber}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: appPadding),
            Padding(
              padding: EdgeInsets.all(4),
              child: Material(
                color: Theme.of(context).colorScheme.surfaceContainer,
                shape: CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    onDelete?.call();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(appPadding),
                    child: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: ColorScheme.of(context).onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
