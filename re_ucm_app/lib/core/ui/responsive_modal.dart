import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';

import 'tokens.dart';

/// Единый responsive-shell модалов: wide → Dialog, narrow → bottom sheet.
/// Раньше ветка была скопирована в `download_modal` и
/// `downloads_list_modal` с разъехавшимися константами
/// (maxWidth 460 vs 520, паддинги 20 vs 24, крестик 10/18/28 vs 14/20/32).
Future<void> showResponsiveAppModal(
  BuildContext context, {
  required Widget Function(
    BuildContext contentCtx,
    VoidCallback close,
    bool isWide,
  )
  contentBuilder,
  double dialogMaxWidth = 480,
  double? dialogMaxHeight,
  EdgeInsets dialogPadding = const EdgeInsets.fromLTRB(20, 20, 20, 20),
  bool dialogScrollable = true,
  double sheetMaxHeightFraction = 0,
  bool sheetScrollable = true,
}) async {
  final isWide =
      MediaQuery.sizeOf(context).width >= AppBreakpoints.mobileNav;
  if (isWide) {
    await showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.dialog),
        ),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: dialogMaxWidth,
            maxHeight: dialogMaxHeight ?? double.infinity,
          ),
          child: Stack(
            children: [
              Builder(
                builder: (contentCtx) {
                  final content = Padding(
                    padding: dialogPadding,
                    child: contentBuilder(
                      dialogCtx,
                      () => Navigator.of(dialogCtx).pop(),
                      true,
                    ),
                  );
                  // Контент со своим скроллом (Flexible+ListView) нельзя
                  // класть в SingleChildScrollView — unbounded height.
                  if (!dialogScrollable) return content;
                  return SingleChildScrollView(child: content);
                },
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  tooltip: 'Закрыть',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  } else {
    await showM3EModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      builder: (sheetCtx) {
        Widget content = contentBuilder(
          sheetCtx,
          () => Navigator.of(sheetCtx).pop(),
          false,
        );
        if (sheetScrollable) {
          content = SingleChildScrollView(child: content);
        }
        if (sheetMaxHeightFraction > 0) {
          final screenHeight = MediaQuery.sizeOf(sheetCtx).height;
          content = ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: screenHeight * sheetMaxHeightFraction,
            ),
            child: content,
          );
        }
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              0,
              16,
              MediaQuery.viewInsetsOf(sheetCtx).bottom + 16,
            ),
            child: content,
          ),
        );
      },
    );
  }
}
