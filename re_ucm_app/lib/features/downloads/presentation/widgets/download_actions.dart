import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';

import '../../../common/widgets/snack.dart';
import '../../domain/download_task.cg.dart';
import 'exporting_indicator.dart';

class DownloadActions extends StatelessWidget {
  const DownloadActions({super.key, required this.task, required this.onClose});

  final DownloadTask task;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        // Одна анимация: AnimatedSwitcher + switch по статусу.
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: switch (task.status) {
            DownloadTaskStatus.completed => KeyedSubtree(
                key: ValueKey('completed_${task.savedFilePath != null}'),
                child: _buildCompleted(context, Theme.of(context)),
              ),
            DownloadTaskStatus.failed ||
            DownloadTaskStatus.cancelled =>
              KeyedSubtree(
                key: const ValueKey('failed'),
                child: _buildFailed(context, Theme.of(context)),
              ),
            _ => KeyedSubtree(
                key: const ValueKey('active'),
                child: _buildActive(context, Theme.of(context)),
              ),
          },
        );
      },
    );
  }

  Widget _buildCompleted(BuildContext context, ThemeData theme) {
    if (task.savedFilePath != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Primary action: Open Book in Reader
          M3EButton.icon(
            style: M3EButtonStyle.filled,
            size: M3EButtonSize.md,
            onPressed: task.isExporting ? null : task.open,
            icon: ExportingIndicator(
              isExporting: task.isExporting,
              icon: Icons.menu_book_rounded,
              size: 18,
              color: theme.colorScheme.onPrimary,
            ),
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
            icon: ExportingIndicator(
              isExporting: task.isExporting,
              icon: Icons.share_outlined,
              size: 18,
            ),
            label: const Text('Поделиться'),
          ),
        ],
      );
    }

    // Book downloaded, not yet saved: balanced row of Share and Save
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: M3EButton.icon(
            style: M3EButtonStyle.outlined,
            size: M3EButtonSize.md,
            onPressed: task.isExporting ? null : task.share,
            icon: ExportingIndicator(
              isExporting: task.isExporting,
              icon: Icons.share_outlined,
              size: 18,
            ),
            label: const Text('Поделиться'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: M3EButton.icon(
            style: M3EButtonStyle.filled,
            size: M3EButtonSize.md,
            onPressed: task.isExporting
                ? null
                : () => _saveWithFeedback(context, task),
            icon: ExportingIndicator(
              isExporting: task.isExporting,
              icon: Icons.save_alt_rounded,
              size: 20,
              color: theme.colorScheme.onPrimary,
            ),
            label: const Text(
              'Сохранить',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
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
            size: M3EButtonSize.md,
            onPressed: onClose,
            child: const Text('Закрыть'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: M3EButton.icon(
            style: M3EButtonStyle.filled,
            size: M3EButtonSize.md,
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
            size: M3EButtonSize.md,
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
            size: M3EButtonSize.md,
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

/// Сохранение с UI-фидбеком. Раньше снэки показывал сам domain
/// ([DownloadTask.save] принимал BuildContext).
Future<void> _saveWithFeedback(
  BuildContext context,
  DownloadTask task,
) async {
  final outcome = await task.save();
  if (!context.mounted) return;
  switch (outcome) {
    case ExportSaved():
      AppSnack.show(context, 'Успешно сохранено', kind: AppSnackKind.success);
    case ExportCancelled():
      AppSnack.show(context, 'Сохранение отменено', kind: AppSnackKind.info);
    case ExportFailed():
      AppSnack.show(
        context,
        'Произошла ошибка при сохранении',
        kind: AppSnackKind.error,
      );
  }
}
