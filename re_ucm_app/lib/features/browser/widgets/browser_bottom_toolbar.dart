import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';

import 'browser_nav_model.dart';
import 'browser_refresh_button.dart';
import 'browser_tooltips.dart';

class BrowserBottomToolbar extends StatelessWidget {
  const BrowserBottomToolbar({super.key, required this.nav});

  final BrowserNavModel nav;

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
                onPressed: nav.canGoBack ? nav.onWebBack : null,
                tooltip: BrowserTooltips.webBack,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: nav.canGoForward ? nav.onWebForward : null,
                tooltip: BrowserTooltips.webForward,
              ),
              BrowserRefreshButton(isLoading: nav.isLoading, onReload: nav.onReload),
            ],
          ),
        ),
        const SizedBox(width: M3EFloatingToolbarDefaults.toolbarToFabGap),
        M3EFab(
          onPressed: nav.hasBook ? nav.onDownload : null,
          color: nav.hasBook ? M3EFabColor.primary : M3EFabColor.surface,
          tooltip: nav.hasBook ? 'Скачать книгу' : null,
          icon: const Icon(Icons.download),
        ),
      ],
    );
  }
}
