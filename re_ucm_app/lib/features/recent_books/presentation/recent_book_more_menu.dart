import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../core/navigation/nav.dart';
import '../../../core/ui/widgets/m3e_spring_popup.dart';
import '../../downloads/domain/download_task.cg.dart';
import 'recent_book_actions.dart';

class RecentBookMoreMenu extends StatelessWidget {
  const RecentBookMoreMenu({
    super.key,
    required this.book,
    required this.task,
    required this.effectiveFilePath,
    required this.fileExists,
    this.showOpen = false,
    this.showShare = false,
    this.onDelete,
  });

  final RecentBook book;
  final DownloadTask? task;
  final String? effectiveFilePath;
  final bool fileExists;
  final bool showOpen;
  final bool showShare;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Builder(
      builder: (btnContext) {
        return IconButton(
          tooltip: 'Дополнительно',
          icon: Icon(
            Icons.more_vert_rounded,
            size: 20,
            color: cs.onSurfaceVariant,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          onPressed: () async {
            HapticFeedback.lightImpact();
            final action = await showM3ESpringPopup<String>(
              targetContext: btnContext,
              items: [
                if (showOpen && fileExists)
                  const M3ESpringPopupItem<String>(
                    value: 'open',
                    label: 'Читать',
                    icon: Icons.menu_book_rounded,
                  ),
                if (showShare && fileExists)
                  const M3ESpringPopupItem<String>(
                    value: 'share',
                    label: 'Поделиться',
                    icon: Icons.share_outlined,
                  ),
                const M3ESpringPopupItem<String>(
                  value: 'browser',
                  label: 'Открыть в браузере',
                  icon: Icons.open_in_browser_rounded,
                ),
                const M3ESpringPopupItem<String>(
                  value: 'delete',
                  label: 'Удалить',
                  icon: Icons.delete_outline_rounded,
                  isDestructive: true,
                ),
              ],
            );
            if (!btnContext.mounted) return;
            switch (action) {
              case 'open':
                await openBook(
                  btnContext,
                  task: task,
                  effectiveFilePath: effectiveFilePath,
                );
              case 'share':
                if (btnContext.mounted) {
                  shareBook(btnContext, task, effectiveFilePath, book);
                }
              case 'browser':
                Nav.goBrowser(book.portal.code);
              case 'delete':
                onDelete?.call();
            }
          },
        );
      },
    );
  }
}
