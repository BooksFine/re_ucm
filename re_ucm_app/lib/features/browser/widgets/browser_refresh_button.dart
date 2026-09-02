import 'package:flutter/material.dart';

class BrowserRefreshButton extends StatelessWidget {
  const BrowserRefreshButton({
    super.key,
    required this.isLoading,
    required this.onReload,
  });

  final bool isLoading;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return IconButton(
        icon: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2.2),
        ),
        onPressed: onReload,
        tooltip: 'Загрузка...',
      );
    }
    return IconButton(
      icon: const Icon(Icons.refresh, size: 24),
      onPressed: onReload,
      tooltip: 'Обновить',
    );
  }
}
