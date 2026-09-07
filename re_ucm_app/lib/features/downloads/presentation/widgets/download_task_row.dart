import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/ui/app_colors_extension.dart';

class DownloadTaskRow extends StatelessWidget {
  const DownloadTaskRow({
    super.key,
    required this.title,
    required this.statusText,
    this.prefix,
    this.progress,
    this.isDownloading = false,
    this.isCompleted = false,
    this.isFailed = false,
  });

  final String title;
  final String statusText;
  final Widget? prefix;
  final double? progress;
  final bool isDownloading;
  final bool isCompleted;
  final bool isFailed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Widget statusIcon = isCompleted
        ? Icon(
            Icons.check_circle_rounded,
            size: 15,
            color: context.appColors.success,
          )
        : isFailed
            ? Icon(
                Icons.error_rounded,
                size: 15,
                color: theme.colorScheme.error,
              )
            : isDownloading
                ? SizedBox(
                    width: 13,
                    height: 13,
                    child: M3ECircularWavyProgressIndicator(
                      size: 13,
                      strokeWidth: 1.5,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.5,
                    ),
                  );

    final hasProgress = isDownloading && progress != null;

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
                    fontWeight: isDownloading
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isDownloading
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: isDownloading
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
