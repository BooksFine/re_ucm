import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_lib/settings/domain/save_format.dart';

import '../../../../core/ui/tokens.dart';
import '../../domain/download_task.cg.dart';

class DownloadActions extends StatelessWidget {
  const DownloadActions({super.key, required this.task, required this.onClose});

  final DownloadTask task;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Observer(
      builder: (context) {
        final Widget content = task.isCompleted
            ? KeyedSubtree(
                key: ValueKey('completed_${task.savedFilePath != null}'),
                child: _buildCompleted(context, theme),
              )
            : (task.isFailed
                  ? KeyedSubtree(
                      key: const ValueKey('failed'),
                      child: _buildFailed(context, theme),
                    )
                  : KeyedSubtree(
                      key: const ValueKey('active'),
                      child: _buildActive(context, theme),
                    ));

        return AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: content,
          ),
        );
      },
    );
  }

  Widget _buildCompleted(BuildContext context, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FormatSelector(task: task),
        const SizedBox(height: 12),

        if (task.savedFilePath != null) ...[
          // Primary action: Open Book in Reader
          M3EButton.icon(
            style: M3EButtonStyle.filled,
            size: M3EButtonSize.md,
            onPressed: task.isExporting ? null : task.open,
            icon: task.isExporting
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: M3ECircularWavyProgressIndicator(
                      size: 18,
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimary,
                    ),
                  )
                : const Icon(Icons.menu_book_rounded, size: 20),
            label: Text(
              task.isExporting ? 'Конвертация...' : 'Открыть книгу',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 8),

          // Secondary action: Share
          M3EButton.icon(
            style: M3EButtonStyle.tonal,
            size: M3EButtonSize.md,
            onPressed: task.isExporting ? null : task.share,
            icon: task.isExporting
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: M3ECircularWavyProgressIndicator(
                      size: 16,
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : const Icon(Icons.share_outlined, size: 18),
            label: const Text('Поделиться'),
          ),
        ] else ...[
          // Book downloaded, not yet saved: balanced row of Share and Save
          Row(
            children: [
              Expanded(
                flex: 1,
                child: M3EButton.icon(
                  style: M3EButtonStyle.outlined,
                  size: M3EButtonSize.md,
                  onPressed: task.isExporting ? null : task.share,
                  icon: task.isExporting
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: M3ECircularWavyProgressIndicator(
                            size: 16,
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : const Icon(Icons.share_outlined, size: 18),
                  label: const Text('Поделиться'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: M3EButton.icon(
                  style: M3EButtonStyle.filled,
                  size: M3EButtonSize.md,
                  onPressed: task.isExporting ? null : () => task.save(context),
                  icon: task.isExporting
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: M3ECircularWavyProgressIndicator(
                            size: 16,
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : const Icon(Icons.save_alt_rounded, size: 20),
                  label: const Text(
                    'Сохранить',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildFailed(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: M3EButton(
            style: M3EButtonStyle.outlined,
            size: M3EButtonSize.sm,
            onPressed: onClose,
            child: const Text('Закрыть'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: M3EButton.icon(
            style: M3EButtonStyle.filled,
            size: M3EButtonSize.sm,
            onPressed: task.retry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text(
              'Повторить',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActive(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: M3EButton.icon(
            style: M3EButtonStyle.outlined,
            size: M3EButtonSize.sm,
            decoration: M3EButtonDecoration.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(
                color: theme.colorScheme.error.withValues(alpha: 0.5),
              ),
            ),
            onPressed: () {
              task.cancel();
              onClose();
            },
            icon: const Icon(Icons.close_rounded, size: 16),
            label: const Text(
              'Отмена',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: M3EButton.icon(
            style: M3EButtonStyle.filled,
            size: M3EButtonSize.sm,
            onPressed: onClose,
            icon: const Icon(Icons.arrow_downward_rounded, size: 18),
            label: const Text(
              'В фон',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _FormatSelector extends StatelessWidget {
  const _FormatSelector({required this.task});

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
            segments: const [
              ButtonSegment<SaveFormat>(
                value: SaveFormat.fb2,
                label: Text('fb2', style: TextStyle(fontSize: 13)),
              ),
              ButtonSegment<SaveFormat>(
                value: SaveFormat.fb2Zip,
                label: Text('fb2.zip', style: TextStyle(fontSize: 13)),
              ),
              ButtonSegment<SaveFormat>(
                value: SaveFormat.epub,
                label: Text('epub', style: TextStyle(fontSize: 13)),
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
