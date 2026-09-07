import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/re_ucm_core.dart';

import '../../downloads/domain/download_task.cg.dart';
import 'models/recent_book_view_state.dart';
import 'recent_book_actions.dart';

class DownloadButton extends StatelessWidget {
  const DownloadButton({
    super.key,
    required this.onPressed,
    this.iconOnly = false,
    this.size = M3EButtonSize.sm,
  });

  final VoidCallback? onPressed;
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
    return Observer(
      builder: (context) {
        final theme = Theme.of(context);
        final cs = theme.colorScheme;
        if (compact) {
          final progress = task?.progress.normalized;
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
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
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
                RecentBookItemState.formatProgress(task),
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
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              onPressed: () => task?.cancel(),
            ),
          ],
        );
      },
    );
  }
}

class ReadButton extends StatelessWidget {
  const ReadButton({
    super.key,
    required this.task,
    required this.effectiveFilePath,
    this.iconOnly = false,
    this.size = M3EButtonSize.sm,
    this.label = 'Читать',
  });

  final DownloadTask? task;
  final String? effectiveFilePath;
  final bool iconOnly;
  final M3EButtonSize size;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final label = this.label;
    if (iconOnly || label == null) {
      return Tooltip(
        message: label ?? 'Читать',
        child: M3EButton(
          style: M3EButtonStyle.tonal,
          size: size,
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
      size: size,
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
