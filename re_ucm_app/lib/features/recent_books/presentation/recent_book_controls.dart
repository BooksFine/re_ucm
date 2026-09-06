import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/re_ucm_core.dart';

import '../../downloads/domain/download_task.cg.dart';
import 'recent_book_actions.dart';

class DownloadButton extends StatelessWidget {
  const DownloadButton({
    super.key,
    required this.onPressed,
    this.iconOnly = false,
    this.size = M3EButtonSize.sm,
  });

  final VoidCallback onPressed;
  final bool iconOnly;
  final M3EButtonSize size;

  @override
  Widget build(BuildContext context) {
    if (iconOnly) {
      return M3EButton(
        style: M3EButtonStyle.tonal,
        size: size,
        shape: M3EButtonShape.round,
        onPressed: onPressed,
        child: const Icon(Icons.download_rounded),
      );
    }
    return M3EButton.icon(
      style: M3EButtonStyle.tonal,
      size: size,
      shape: M3EButtonShape.round,
      icon: const Icon(Icons.download_rounded),
      label: const Text('Скачать'),
      onPressed: onPressed,
    );
  }
}

class RecentBookDownloadingRow extends StatelessWidget {
  const RecentBookDownloadingRow({
    super.key,
    required this.task,
    this.compact = false,
  });

  final DownloadTask? task;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final progress = task?.progress.normalized;
    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: M3ECircularWavyProgressIndicator(
              value: progress,
              size: 22,
              strokeWidth: 2.2,
              color: cs.primary,
            ),
          ),
          IconButton(
            tooltip: 'Отменить',
            icon: const Icon(Icons.close_rounded, size: 20),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () => task?.cancel(),
          ),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            progress != null
                ? 'Загрузка ${(progress * 100).toInt()}%'
                : 'Загрузка...',
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 10,
              color: cs.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Отменить',
          icon: const Icon(Icons.close_rounded, size: 18),
          visualDensity: VisualDensity.compact,
          onPressed: () => task?.cancel(),
        ),
      ],
    );
  }
}

class ReadButton extends StatelessWidget {
  const ReadButton({
    super.key,
    required this.task,
    required this.effectiveFilePath,
    this.label,
  });

  final DownloadTask? task;
  final String? effectiveFilePath;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final label = this.label;
    if (label == null) {
      return Tooltip(
        message: 'Читать',
        child: M3EButton(
          style: M3EButtonStyle.tonal,
          size: M3EButtonSize.sm,
          shape: M3EButtonShape.round,
          onPressed: () => openBook(
            context,
            task: task,
            effectiveFilePath: effectiveFilePath,
          ),
          child: const Icon(Icons.menu_book_rounded),
        ),
      );
    }
    return M3EButton.icon(
      style: M3EButtonStyle.tonal,
      size: M3EButtonSize.sm,
      shape: M3EButtonShape.round,
      icon: const Icon(Icons.menu_book_rounded),
      label: Text(label),
      onPressed: () => openBook(
        context,
        task: task,
        effectiveFilePath: effectiveFilePath,
      ),
    );
  }
}
