import 'package:flutter/material.dart';
import '../../common/widgets/appbar.dart';
import 'browser_refresh_button.dart';

class BrowserAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize = const Size.fromHeight(kToolbarHeight);

  const BrowserAppBar({
    super.key,
    required this.title,
    required this.isWide,
    required this.canGoBack,
    required this.canGoForward,
    required this.isLoading,
    required this.hasBook,
    required this.onBackToApp,
    required this.onWebBack,
    required this.onWebForward,
    required this.onReload,
    required this.onDownload,
    required this.onOpenSettings,
  });

  final String title;
  final bool isWide;
  final bool canGoBack;
  final bool canGoForward;
  final bool isLoading;
  final bool hasBook;
  final VoidCallback onBackToApp;
  final VoidCallback? onWebBack;
  final VoidCallback? onWebForward;
  final VoidCallback onReload;
  final VoidCallback? onDownload;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 2,
      child: MyAppBar(
        title: title,
        leading: isWide
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onBackToApp,
                    icon: const Icon(Icons.arrow_back_ios_new),
                    tooltip: 'Назад в приложение',
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
                          onPressed: canGoBack ? onWebBack : null,
                          tooltip: 'Назад по сайту',
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward, size: 24),
                          onPressed: canGoForward ? onWebForward : null,
                          tooltip: 'Вперёд по сайту',
                        ),
                        BrowserRefreshButton(
                          isLoading: isLoading,
                          onReload: onReload,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : IconButton(
                onPressed: onBackToApp,
                icon: const Icon(Icons.arrow_back_ios_new),
              ),
        actions: [
          if (isWide) ...[
            SizedBox(
              height: 40,
              child: FilledButton.tonalIcon(
                onPressed: hasBook ? onDownload : null,
                icon: const Icon(Icons.download),
                label: const Text('Скачать'),
                style: FilledButton.styleFrom(
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: onOpenSettings,
            tooltip: 'Настройки',
          ),
        ],
      ),
    );
  }
}
