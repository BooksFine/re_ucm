import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../../core/di.dart';

class RecentBooksHeader extends StatelessWidget {
  const RecentBooksHeader({
    super.key,
    this.padding = EdgeInsets.zero,
  });

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final deps = AppDependencies.of(context);
    final controller = deps.settingsController;

    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Последние книги',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
          ),
          Observer(
            builder: (_) {
              final isCompact =
                  controller.recentBooksViewMode == RecentBooksViewMode.compact;

              return IconButton(
                tooltip: isCompact ? 'Подробный вид' : 'Компактный вид',
                visualDensity: VisualDensity.compact,
                style: IconButton.styleFrom(
                  minimumSize: const Size(44, 44),
                  padding: const EdgeInsets.all(8),
                ),
                icon: Icon(
                  isCompact
                      ? Icons.view_agenda_outlined
                      : Icons.view_headline_rounded,
                  size: 18,
                  color: cs.onSurfaceVariant,
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  controller.updateRecentBooksViewMode(
                    isCompact
                        ? RecentBooksViewMode.detailed
                        : RecentBooksViewMode.compact,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
