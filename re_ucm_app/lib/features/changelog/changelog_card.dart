import 'package:material_ui/material_ui.dart';
import '../../core/ui/tokens.dart';

import 'changelog.dart';

class ChangelogCard extends StatelessWidget {
  const ChangelogCard({super.key, required this.model});

  final Changelog model;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: BorderSide(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: 0.8,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
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
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                model.content,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (model.technicalDetails != null)
              ExpansionTile(
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
                title: Text(
                  'Технические подробности',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                childrenPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
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
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),

            if (model.technicalDetails == null)
              const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
