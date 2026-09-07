import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/ui/tokens.dart';
import '../../../common/widgets/book_cover_image.dart';
import '../../domain/download_task.cg.dart';
import '../models/download_status_viewmodel.dart';

/// Тайл задачи для карточек в модалке со списком загрузок.
class DownloadHistoryListTile extends StatelessWidget {
  const DownloadHistoryListTile({
    super.key,
    required this.task,
    this.onTap,
  });

  final DownloadTask task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final vm = task.viewModel;
        final meta = task.metadata;
        final coverUrl = meta?.cover?.ref.id;

        final theme = Theme.of(context);
        final isCompleted = task.isCompleted;
        final isActive = task.isActive;
        final isFailed = task.isFailed;
        final tot = task.progress.total ?? 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  BookCoverImage(
                    coverUrl: (coverUrl?.isNotEmpty == true) ? coverUrl : null,
                    width: 44,
                    height: 60,
                    iconSize: 22,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          vm.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        if (isActive) ...[
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  vm.statusText,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (tot > 0 && vm.progress != null) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '${(vm.progress! * 100).toInt()}%',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 5),
                          M3ELinearWavyProgressIndicator(
                            value: vm.progress,
                            height: 6,
                            strokeWidth: 3,
                            backgroundColor: theme.colorScheme.primary.withValues(
                              alpha: 0.15,
                            ),
                          ),
                        ] else if (isCompleted) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 15,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                task.savedFilePath != null
                                    ? 'Сохранено'
                                    : 'Готово к сохранению',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ] else if (isFailed) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.error_rounded,
                                size: 15,
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Ошибка загрузки',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
