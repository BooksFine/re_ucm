import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/re_ucm_core.dart' hide logger;

import '../../../../core/ui/tokens.dart';
import '../../../common/widgets/book_cover_image.dart';
import '../../domain/download_task.cg.dart';
import '../models/download_status_viewmodel.dart';

/// Компактный тайл активной загрузки для live-карточки.
class LiveDownloadCompactTile extends StatelessWidget {
  const LiveDownloadCompactTile({
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
        final authors = meta?.authorsDisplay ?? task.session.portal.name;

        final theme = Theme.of(context);
        final cs = theme.colorScheme;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: cs.primaryContainer.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(
              color: cs.primary.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadii.card),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        BookCoverImage(
                          coverUrl: coverUrl,
                          width: 38,
                          height: 52,
                          iconSize: 20,
                          errorIcon: Icons.downloading_rounded,
                          placeholderIcon: Icons.downloading_rounded,
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                vm.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                authors,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                vm.statusText,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        IconButton(
                          tooltip: 'Отменить загрузку',
                          icon: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: cs.error,
                          ),
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(
                            minWidth: 44,
                            minHeight: 44,
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            task.cancel();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    M3ELinearWavyProgressIndicator(
                      value: vm.progress,
                      height: 6,
                      strokeWidth: 3,
                      color: cs.primary,
                      backgroundColor: cs.primary.withValues(alpha: 0.15),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
