import 'package:material_ui/material_ui.dart';

/// Единая модель навигации браузера: убирает проп-дриллинг
/// (раньше 11 параметров в AppBar и 8 в BottomToolbar дублировались
/// из BrowserState). Один объект строится в [Browser] за билд.
@immutable
class BrowserNavModel {
  const BrowserNavModel({
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
}
