import 'package:flutter/material.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:re_ucm_core/models/portal.dart';
import 'package:webview_all/webview_all.dart';

import '../../core/navigation/router_delegate.dart';
import '../common/widgets/webview.dart';
import '../settings/presentation/settings_dialog.dart';
import 'widgets/browser_app_bar.dart';
import 'widgets/browser_bottom_toolbar.dart';
import 'widgets/scroll_to_hide_bottom_bar.dart';

class Browser extends StatefulWidget {
  const Browser({super.key, required this.portal});

  final Portal portal;

  @override
  State<Browser> createState() => _BrowserState();
}

class _BrowserState extends State<Browser> {
  WebViewController? _webViewController;
  bool canGoBack = false;
  bool canGoForward = false;
  String? _currentBookId;
  bool _isLoading = false;

  void _reload() {
    setState(() => _isLoading = true);
    _webViewController?.reload();
  }

  void _updateNavButtons() async {
    if (_webViewController == null) return;
    final back = await _webViewController!.canGoBack();
    final forward = await _webViewController!.canGoForward();
    if (mounted) {
      setState(() {
        canGoBack = back;
        canGoForward = forward;
      });
    }
  }

  void _checkUrl(Uri? url) {
    if (url == null) return;
    try {
      final bookId = widget.portal.service.getIdFromUrl(url);
      if (_currentBookId != bookId) {
        setState(() => _currentBookId = bookId);
      }
    } catch (_) {
      if (_currentBookId != null) {
        setState(() => _currentBookId = null);
      }
    }
  }

  void _onNavigationChanged(Uri? url) {
    _updateNavButtons();
    _checkUrl(url);
  }

  void _onDownloadPressed() {
    if (_currentBookId == null) return;
    Nav.bookFromBrowser(widget.portal.code, _currentBookId!);
  }

  Widget _buildWebView({required bool isWide}) {
    return AppWebView(
      initialUrl: Uri.parse(widget.portal.url),
      userAgent: isWide
          ? null
          : 'Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36',
      onWebViewCreated: (controller) => _webViewController = controller,
      onLoadStart: (controller, url) {
        setState(() => _isLoading = true);
        _onNavigationChanged(url);
      },
      onProgress: (controller, progress) {
        if (progress >= 100 && _isLoading) {
          setState(() => _isLoading = false);
        }
      },
      onLoadStop: (controller, url) {
        setState(() => _isLoading = false);
        _onNavigationChanged(url);
      },
      onUpdateVisitedHistory: (controller, url) {
        _onNavigationChanged(url);
      },
      shouldOverrideUrlLoading: (controller, request) async {
        final uri = Uri.parse(request.url);
        _checkUrl(uri);
        return NavigationDecision.navigate;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 600;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final bottomBarHeight =
        M3EFloatingToolbarDefaults.containerSize + 16.0 + bottomPadding;

    return PopScope(
      canPop: !canGoBack,
      onPopInvokedWithResult: (_, _) {
        _webViewController?.goBack();
      },
      child: Scaffold(
        appBar: BrowserAppBar(
          title: widget.portal.name,
          isWide: isWide,
          canGoBack: canGoBack,
          canGoForward: canGoForward,
          isLoading: _isLoading,
          hasBook: _currentBookId != null,
          onBackToApp: Nav.back,
          onWebBack: _webViewController?.goBack,
          onWebForward: _webViewController?.goForward,
          onReload: _reload,
          onDownload: _onDownloadPressed,
          onOpenSettings: () => openSettingsDialog(context),
        ),
        body: isWide
            ? _buildWebView(isWide: true)
            : ScrollToHideBottomBar(
                bottomBarHeight: bottomBarHeight,
                bottomPadding: bottomPadding,
                bottomBar: BrowserBottomToolbar(
                  canGoBack: canGoBack,
                  canGoForward: canGoForward,
                  isLoading: _isLoading,
                  hasBook: _currentBookId != null,
                  onWebBack: _webViewController?.goBack,
                  onWebForward: _webViewController?.goForward,
                  onReload: _reload,
                  onDownload: _onDownloadPressed,
                ),
                child: _buildWebView(isWide: false),
              ),
      ),
    );
  }
}
