import 'package:flutter/material.dart';
import '../../../../../core/ui/constants.dart';

enum TaskRowStatus { pending, downloading, completed, failed }

class TaskRow extends StatelessWidget {
  const TaskRow({
    super.key,
    required this.status,
    required this.title,
    this.prefix,
    required this.statusText,
    this.progress,
  });

  final TaskRowStatus status;
  final String title;
  final Widget? prefix;
  final String statusText;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Widget statusIcon = switch (status) {
      TaskRowStatus.completed => Icon(
        Icons.check_circle,
        size: 16,
        color: Colors.green.shade400,
      ),
      TaskRowStatus.failed => Icon(
        Icons.error,
        size: 16,
        color: theme.colorScheme.error,
      ),
      TaskRowStatus.downloading => SizedBox(
        width: 18,
        height: 18,
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      TaskRowStatus.pending => Icon(
        Icons.schedule,
        size: 16,
        color: theme.disabledColor,
      ),
    };

    final hasProgress = status == TaskRowStatus.downloading && progress != null;

    return SizedBox(
      height: hasProgress ? 30 : 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 24,
            child: Row(
              children: [
                statusIcon,
                const SizedBox(width: appPadding),
                if (prefix != null) ...[
                  prefix!,
                  const SizedBox(width: appPadding / 2),
                ],
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                const SizedBox(width: appPadding),
                Text(
                  statusText,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (hasProgress)
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: double.infinity,
                  height: 2,
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 2,
                    borderRadius: BorderRadius.circular(1),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
