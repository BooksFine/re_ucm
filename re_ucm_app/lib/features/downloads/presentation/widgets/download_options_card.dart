import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_lib/settings/domain/save_format.dart';

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
        final showFormatSelector = task.isCompleted;

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showFormatSelector) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                  child: DownloadFormatSelector(task: task),
                ),
                Divider(
                  height: 1,
                  thickness: 0.6,
                  indent: 12,
                  endIndent: 12,
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.25,
                  ),
                ),
              ],
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
        );
      },
    );
  }
}

class DownloadFormatSelector extends StatelessWidget {
  const DownloadFormatSelector({super.key, required this.task});

  final DownloadTask task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Формат сохранения:',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (task.isExporting)
              Text(
                'Конвертация...',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<SaveFormat>(
            style: SegmentedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              visualDensity: VisualDensity.compact,
            ),
            showSelectedIcon: false,
            segments: [
              for (final fmt in SaveFormat.displayValues)
                ButtonSegment<SaveFormat>(
                  value: fmt,
                  label: Text(fmt.label, style: const TextStyle(fontSize: 13)),
                ),
            ],
            selected: {task.saveFormat},
            onSelectionChanged: task.isExporting
                ? null
                : (Set<SaveFormat> newSelection) {
                    if (newSelection.isNotEmpty) {
                      task.updateSaveFormat(newSelection.first);
                    }
                  },
          ),
        ),
      ],
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
