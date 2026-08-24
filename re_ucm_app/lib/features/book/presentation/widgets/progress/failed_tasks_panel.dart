import 'package:flutter/material.dart';
import 'package:re_ucm_core/models/progress.dart';
import '../../../../../core/ui/constants.dart';
import '../../../../common/widgets/outlined_btn.dart';

class FailedTasksPanel extends StatelessWidget {
  const FailedTasksPanel({
    super.key,
    required this.tasks,
    required this.isLoading,
    required this.onRetry,
  });

  final List<ImageDownloadTask> tasks;
  final bool isLoading;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: appPadding * 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cardBorderRadius),
        border: Border.all(color: theme.colorScheme.error, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(appPadding * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 18,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: appPadding),
                const Text(
                  'Не удалось загрузить изображения:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: appPadding),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                primary: false,
                shrinkWrap: true,
                itemCount: tasks.length,
                separatorBuilder: (_, _) => const SizedBox(height: appPadding),
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return Row(
                    children: [
                      Icon(
                        Icons.error,
                        size: 16,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: appPadding),
                      Expanded(
                        child: Text(
                          task.id,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: appPadding * 2),
            OutlinedButton1(
              text: 'Повторить',
              isLoading: isLoading,
              func: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
