import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/models/progress.dart';

import '../../../../core/ui/tokens.dart';

class FailedTasksCard extends StatefulWidget {
  const FailedTasksCard({
    super.key,
    required this.tasks,
    required this.onRetry,
    required this.onIgnore,
    this.isLoading = false,
  });

  final List<ImageDownloadTask> tasks;
  /// Async-колбэки: ошибки ретрая не должны теряться молча
  /// (раньше `VoidCallback` стирал Future от `retryFailedImages`).
  final Future<void> Function() onRetry;
  final VoidCallback onIgnore;
  final bool isLoading;

  @override
  State<FailedTasksCard> createState() => _FailedTasksCardState();
}

class _FailedTasksCardState extends State<FailedTasksCard> {
  bool _isExpanded = false;

  static String _pluralizeImages(int count) {
    final rem100 = count % 100;
    final rem10 = count % 10;
    if (rem100 >= 11 && rem100 <= 14) {
      return 'картинок';
    }
    if (rem10 == 1) {
      return 'картинку';
    }
    if (rem10 >= 2 && rem10 <= 4) {
      return 'картинки';
    }
    return 'картинок';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tasks.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final count = widget.tasks.length;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.4),
          width: 0.8,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header (Tappable to expand / collapse)
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Не удалось скачать $count ${_pluralizeImages(count)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: theme.colorScheme.error,
                  ),
                ],
              ),
            ),
          ),

          // Collapsible list of failed images
          if (_isExpanded) ...[
            Divider(
              height: 1,
              thickness: 0.5,
              color: theme.colorScheme.error.withValues(alpha: 0.2),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 120),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                shrinkWrap: true,
                primary: false,
                itemCount: widget.tasks.length,
                separatorBuilder: (_, _) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final task = widget.tasks[index];
                  return Row(
                    children: [
                      Icon(
                        Icons.broken_image_outlined,
                        size: 14,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          task.id,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],

          // Action Buttons: "Пропустить" (забить) and "Повторить"
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
            child: Row(
              children: [
                Expanded(
                  child: M3EButton(
                    style: M3EButtonStyle.outlined,
                    size: M3EButtonSize.sm,
                    onPressed: widget.isLoading ? null : widget.onIgnore,
                    child: const Text(
                      'Пропустить',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: M3EButton.icon(
                    style: M3EButtonStyle.filled,
                    size: M3EButtonSize.sm,
                    decoration: M3EButtonDecoration.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                    ),
                    onPressed: widget.isLoading ? null : widget.onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 14),
                    label: const Text(
                      'Повторить',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
