import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import '../../common/widgets/appbar.dart';
import '../../downloads/presentation/widgets/downloads_indicator_button.dart';
import 'browser_nav_model.dart';
import 'browser_refresh_button.dart';
import 'browser_tooltips.dart';

class BrowserAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize = const Size.fromHeight(kToolbarHeight);

  const BrowserAppBar({super.key, required this.nav});

  final BrowserNavModel nav;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 2,
      child: MyAppBar(
        title: nav.title,
        leading: nav.isWide
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: nav.onBackToApp,
                    icon: const Icon(Icons.arrow_back_ios_new),
                    tooltip: BrowserTooltips.backToApp,
                  ),
                  const SizedBox(width: 6),
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, size: 24),
                          onPressed: nav.canGoBack ? nav.onWebBack : null,
                          tooltip: BrowserTooltips.webBack,
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward, size: 24),
                          onPressed: nav.canGoForward ? nav.onWebForward : null,
                          tooltip: BrowserTooltips.webForward,
                        ),
                        BrowserRefreshButton(
                          isLoading: nav.isLoading,
                          onReload: nav.onReload,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : IconButton(
                onPressed: nav.onBackToApp,
                icon: const Icon(Icons.arrow_back_ios_new),
              ),
        actions: [
          const DownloadsIndicatorButton(),
          if (nav.isWide) ...[
            const SizedBox(width: 8),
            M3EButton.icon(
              style: M3EButtonStyle.tonal,
              size: M3EButtonSize.sm,
              onPressed: nav.hasBook ? nav.onDownload : null,
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Скачать'),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: nav.onOpenSettings,
            tooltip: 'Настройки',
          ),
        ],
      ),
    );
  }
}
