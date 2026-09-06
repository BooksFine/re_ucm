import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';

import 'browser_refresh_button.dart';
import 'browser_tooltips.dart';

class BrowserBottomToolbar extends StatelessWidget {
  const BrowserBottomToolbar({
    super.key,
    required this.canGoBack,
    required this.canGoForward,
    required this.isLoading,
    required this.hasBook,
    required this.onWebBack,
    required this.onWebForward,
    required this.onReload,
    required this.onDownload,
  });

  final bool canGoBack;
  final bool canGoForward;
  final bool isLoading;
  final bool hasBook;
  final VoidCallback? onWebBack;
  final VoidCallback? onWebForward;
  final VoidCallback onReload;
  final VoidCallback? onDownload;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        M3EHorizontalFloatingToolbar(
          expanded: true,
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: canGoBack ? onWebBack : null,
                tooltip: BrowserTooltips.webBack,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: canGoForward ? onWebForward : null,
                tooltip: BrowserTooltips.webForward,
              ),
              BrowserRefreshButton(isLoading: isLoading, onReload: onReload),
            ],
          ),
        ),
        const SizedBox(width: M3EFloatingToolbarDefaults.toolbarToFabGap),
        M3EFab(
          onPressed: hasBook ? onDownload : null,
          color: hasBook ? M3EFabColor.primary : M3EFabColor.surface,
          tooltip: hasBook ? 'Скачать книгу' : null,
          icon: const Icon(Icons.download),
        ),
      ],
    );
  }
}
