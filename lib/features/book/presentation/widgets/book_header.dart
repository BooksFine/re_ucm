import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:re_ucm_core/models/book.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../core/constants.dart';
import '../../../common/widgets/shimmer.dart';

class BookHeader extends StatelessWidget {
  const BookHeader({
    super.key,
    required this.book,
  });

  final Book book;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (book.coverUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(cardBorderRadius),
            child: CachedNetworkImage(
              placeholder: (context, url) {
                return ShimmerEffect(
                  Container(
                    width: 110,
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(cardBorderRadius),
                      color: Colors.white,
                    ),
                  ),
                );
              },
              imageUrl: book.coverUrl!,
              width: 110,
              height: 160,
              fit: BoxFit.fill,
            ),
          )
        else
          const Card(
            margin: EdgeInsets.zero,
            child: SizedBox(
              width: 110,
              height: 160,
              child: Center(
                child: Icon(Icons.image),
              ),
            ),
          ),
        const SizedBox(width: appPadding * 2),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: appPadding),
              Text(
                book.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(book.authors.map((e) => e.name).join(', ')),
              if (book.textLength != null)
                Padding(
                  padding: const EdgeInsets.only(top: appPadding * 2),
                  child: Text(
                    "${_formatNumber(book.textLength!)} зн."
                    " • ${(book.textLength! / 40000).toStringAsFixed(1)} а.л.",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.8),
                        ),
                  ),
                ),
              const SizedBox(height: appPadding * 2),
              if (book.series != null)
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Цикл: '),
                      TextSpan(
                        text: book.series!.name,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrlString(
                              book.series!.url,
                              mode: LaunchMode.externalApplication,
                            );
                          },
                      ),
                      const TextSpan(text: ' • '),
                      TextSpan(text: book.series!.number.toString()),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

String _formatNumber(int number) {
  return number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match match) => '${match.group(0)} ',
      );
}
