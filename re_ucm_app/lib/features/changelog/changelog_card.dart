import 'package:flutter/material.dart';
import '../../core/ui/constants.dart';

import 'changelog.dart';

class ChangelogCard extends StatelessWidget {
  const ChangelogCard({super.key, required this.model});

  final Changelog model;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ColorScheme.of(context).surfaceTint.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: appPadding * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: appPadding * 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  model.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  model.date,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: appPadding),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: appPadding),
              child: Text(
                model.content,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (model.technicalDetails != null)
              ExpansionTile(
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  'Технические подробности',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                tilePadding: const EdgeInsets.symmetric(horizontal: appPadding),
                childrenPadding: const EdgeInsets.symmetric(
                  horizontal: appPadding,
                ),
                expandedAlignment: Alignment.centerLeft,
                children: [
                  Text(
                    model.technicalDetails!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: appPadding * 2),
                ],
              ),

            if (model.technicalDetails == null)
              const SizedBox(height: appPadding * 2),
          ],
        ),
      ),
    );
  }
}
