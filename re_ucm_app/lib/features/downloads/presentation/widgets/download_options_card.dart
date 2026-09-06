import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/ui/tokens.dart';
import '../../domain/download_task.cg.dart';

class DownloadOptionsCard extends StatelessWidget {
  const DownloadOptionsCard({super.key, required this.task});

  final DownloadTask task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Observer(
      builder: (_) {
        final showCompletionOption = task.isActive;

        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
              width: 0.6,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: AnimatedSize(
            duration: AppDurations.expand,
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _OptionRow(
                  value: task.addToRecent,
                  onChanged: task.updateAddToRecent,
                  title: 'Добавить в "Последние"',
                  subtitle: 'Для быстрой дозагрузки новых глав',
                ),
                if (showCompletionOption) ...[
                  Divider(
                    height: 1,
                    thickness: 0.6,
                    indent: 12,
                    endIndent: 12,
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.25,
                    ),
                  ),
                  _OptionRow(
                    value: task.showResultOnComplete,
                    onChanged: task.updateShowResultOnComplete,
                    title: 'Окно по завершении',
                    subtitle: 'Показать диалог сохранения после загрузки',
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.value,
    required this.onChanged,
    required this.title,
    required this.subtitle,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: value,
                onChanged: (v) => onChanged(v ?? false),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.xs),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
