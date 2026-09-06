import 'package:material_ui/material_ui.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets/app_card.dart';

import 'changelog.dart';

class ChangelogCard extends StatelessWidget {
  const ChangelogCard({super.key, required this.model});

  final Changelog model;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      titleWidget: AppCardTitle.text(model.title),
      subtitleWidget: Text(
        model.date,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      children: [
        Text(
          model.content,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (model.technicalDetails != null) ...[
          const SizedBox(height: AppSpacing.sm),
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
        ] else
          const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
