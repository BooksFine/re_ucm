import 'package:flutter/material.dart';
import 'package:m3e_core/m3e_core.dart';
import 'browser_refresh_button.dart';

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
                tooltip: 'Назад',
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: canGoForward ? onWebForward : null,
                tooltip: 'Вперёд',
              ),
              BrowserRefreshButton(
                isLoading: isLoading,
                onReload: onReload,
              ),
            ],
          ),
        ),
        const SizedBox(width: M3EFloatingToolbarDefaults.toolbarToFabGap),
        FloatingActionButton(
          heroTag: 'browser_download_fab',
          onPressed: hasBook ? onDownload : null,
          backgroundColor: hasBook
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          foregroundColor: hasBook
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withValues(alpha: 0.38),
          elevation: hasBook ? 2 : 0,
          tooltip: hasBook ? 'Скачать книгу' : null,
          child: const Icon(Icons.download),
        ),
      ],
    );
  }
}
