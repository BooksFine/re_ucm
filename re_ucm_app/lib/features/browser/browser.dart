import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:re_ucm_core/models/portal.dart';

import '../../core/navigation/router_delegate.dart';
import '../common/widgets/appbar.dart';
import '../common/widgets/webview.dart';
import '../settings/presentation/settings_dialog.dart';

class Browser extends StatefulWidget {
  const Browser({super.key, required this.portal});

  final Portal portal;

  @override
  State<Browser> createState() => _BrowserState();
}

class _BrowserState extends State<Browser> {
  InAppWebViewController? _webViewController;
  bool canGoBack = false;
  bool canGoForward = false;

  void _updateNavButtons() async {
    if (_webViewController == null) return;
    final back = await _webViewController!.canGoBack();
    final forward = await _webViewController!.canGoForward();
    setState(() {
      canGoBack = back;
      canGoForward = forward;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: widget.portal.name,
        leading: const IconButton(
          onPressed: Nav.back,
          icon: Icon(Icons.arrow_back_ios_new),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => openSettingsDialog(context),
          ),
        ],
      ),
      floatingActionButton: Card(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: canGoBack ? _webViewController?.goBack : null,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: canGoForward ? _webViewController?.goForward : null,
            ),
          ],
        ),
      ),
      body: AppWebView(
        initialUrl: WebUri(widget.portal.url),
        userAgent:
            'Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36',
        onWebViewCreated: (controller) => _webViewController = controller,
        extraChildren: [
          PopScope(
            canPop: !canGoBack,
            onPopInvokedWithResult: (_, _) {
              _webViewController?.goBack();
            },
            child: const SizedBox.shrink(),
          ),
        ],
        onPermissionRequest: (controller, request) async {
          return PermissionResponse(
            resources: request.resources,
            action: PermissionResponseAction.GRANT,
          );
        },
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          var uri = navigationAction.request.url!;
          try {
            final bookId = widget.portal.service.getIdFromUrl(uri);
            Nav.bookFromBrowser(widget.portal.code, bookId);
            return NavigationActionPolicy.CANCEL;
          } catch (e) {
            return NavigationActionPolicy.ALLOW;
          }
        },
        onUpdateVisitedHistory: (controller, url, isReload) {
          _updateNavButtons();
          if (isReload == true) return;
          try {
            final bookId = widget.portal.service.getIdFromUrl(
              url!.uriValue,
            );
            Nav.bookFromBrowser(widget.portal.code, bookId);
          } catch (e) {
            {}
          }
        },
      ),
    );
  }
}
