import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/ui/app_colors_extension.dart';

enum DownloadTaskRowStatus { pending, downloading, completed, failed }

class DownloadTaskRow extends StatelessWidget {
  const DownloadTaskRow({
    super.key,
    required this.status,
    required this.title,
    this.prefix,
    required this.statusText,
    this.progress,
  });

  final DownloadTaskRowStatus status;
  final String title;
  final Widget? prefix;
  final String statusText;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Widget statusIcon = switch (status) {
      DownloadTaskRowStatus.completed => Icon(
        Icons.check_circle_rounded,
        size: 15,
        color: context.appColors.success,
      ),
      DownloadTaskRowStatus.failed => Icon(
        Icons.error_rounded,
        size: 15,
        color: theme.colorScheme.error,
      ),
      DownloadTaskRowStatus.downloading => SizedBox(
        width: 13,
        height: 13,
        child: M3ECircularWavyProgressIndicator(
          size: 13,
          strokeWidth: 1.5,
          color: theme.colorScheme.primary,
        ),
      ),
      DownloadTaskRowStatus.pending => Icon(
        Icons.schedule_rounded,
        size: 14,
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
    };

    final hasProgress =
        status == DownloadTaskRowStatus.downloading && progress != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 22,
          child: Row(
            children: [
              statusIcon,
              const SizedBox(width: 8),
              if (prefix != null) ...[prefix!, const SizedBox(width: 4)],
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    fontWeight: status == DownloadTaskRowStatus.downloading
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: status == DownloadTaskRowStatus.downloading
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: status == DownloadTaskRowStatus.downloading
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        if (hasProgress) ...[
          const SizedBox(height: 2),
          M3ELinearWavyProgressIndicator(
            value: progress,
            height: 4,
            strokeWidth: 2,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ],
      ],
    );
  }
}
