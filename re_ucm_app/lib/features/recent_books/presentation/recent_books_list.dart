import 'dart:math';

import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';
import 'package:text_balancer/text_balancer.dart';

import '../../../core/di.dart';
import '../../../core/ui/tokens.dart';
import '../../settings/presentation/settings_controller.cg.dart';
import '../domain/recent_book_item_state.dart';
import 'animated_recent_book_card.dart';

class RecentBooksList extends StatefulWidget {
  const RecentBooksList({super.key});

  @override
  State<RecentBooksList> createState() => _RecentBooksListState();
}

class _RecentBooksListState extends State<RecentBooksList> {
  late RecentBooksService service;
  late SettingsController settingsController;

  @override
  void didChangeDependencies() {
    final deps = AppDependencies.of(context);
    service = deps.recentBooksService;
    settingsController = deps.settingsController;
    super.didChangeDependencies();
  }

  void showUndoSnackBar(RecentBook book) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        persist: false,
        width: min(500, MediaQuery.sizeOf(context).width - 32),
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.horizontal,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        content: TextBalancer('Удалено «${book.title}»'),
        action: SnackBarAction(
          label: 'Отменить',
          onPressed: () => service.restoreRecentBook(book),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 120),
      child: Observer(
        builder: (_) {
          return AnimatedSwitcher(
            duration: Durations.medium2,
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            layoutBuilder: (currentChild, previousChildren) => Stack(
              alignment: Alignment.topCenter,
              children: [
                ...previousChildren,
                ?currentChild,
              ],
            ),
            child: () {
              if (service.recentBooks.isEmpty) {
                return Center(
                  key: const ValueKey('recent_books_empty'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_stories_outlined,
                          size: 44,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.35),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'История пуста',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Скачанные книги появятся здесь для быстрой дозагрузки',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              final viewMode = settingsController.recentBooksViewMode;
              return Column(
                key: ValueKey('recent_books_list_${viewMode.name}'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(service.recentBooks.length, (index) {
                  final i = service.recentBooks.length - index - 1;
                  return AnimatedRecentBookCard(
                    key: ValueKey(
                      RecentBook.keyFor(
                        service.recentBooks[i].portal.code,
                        service.recentBooks[i].id,
                      ),
                    ),
                    book: service.recentBooks[i],
                    viewMode: viewMode,
                    onDelete: (book) {
                      RecentBookItemState.invalidateFileCache(
                        book.savedFilePath,
                      );
                      showUndoSnackBar(book);
                      service.removeRecentBook(book);
                    },
                    isFirst: index == 0,
                  );
                }),
              );
            }(),
          );
        },
      ),
    );
  }
}
