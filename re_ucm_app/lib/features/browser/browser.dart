import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:re_ucm_core/models/portal.dart';

import '../../core/navigation/router_delegate.dart';
import '../common/utils/external_launcher.dart';
import '../common/widgets/appbar.dart';
import '../settings/presentation/settings_dialog.dart';

class Browser extends StatefulWidget {
  const Browser({super.key, required this.portal});

  final Portal portal;

  @override
  State<Browser> createState() => _BrowserState();
}

class _BrowserState extends State<Browser> {
  bool isLoading = true;
  double progress = 0;

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

  bool isPageOpened = false;

  @override
  initState() {
    Future.delayed(Durations.short4, () {
      isPageOpened = true;
      setState(() {});
    });

    super.initState();
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
      body: Stack(
        children: [
          PopScope(
            canPop: !canGoBack,
            onPopInvokedWithResult: (_, _) {
              _webViewController?.goBack();
            },
            child: SizedBox.shrink(),
          ),

          if (isPageOpened)
            InAppWebView(
              initialSettings: InAppWebViewSettings(
                useShouldOverrideUrlLoading: true,
                useHybridComposition: true,
                userAgent:
                    'Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36',
              ),
              onWebViewCreated: (controller) => _webViewController = controller,
              onPermissionRequest: (controller, request) async {
                return PermissionResponse(
                  resources: request.resources,
                  action: PermissionResponseAction.GRANT,
                );
              },
              initialUrlRequest: URLRequest(url: WebUri(widget.portal.url)),
              onLoadStart: (controller, url) {
                isLoading = true;
                setState(() {});
              },
              onLoadStop: (controller, url) async {
                isLoading = false;
                setState(() {});
              },
              onProgressChanged: (controller, progress) {
                this.progress = progress / 100;
                setState(() {});
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                var uri = navigationAction.request.url!;
                if (uri.scheme != 'http' && uri.scheme != 'https') {
                  await launchExternalUrl(context, uri);
                  return NavigationActionPolicy.CANCEL;
                }
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

          AnimatedOpacity(
            duration: Durations.medium2,
            opacity: isLoading ? 1 : 0,
            child: TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: progress),
              duration: Durations.short4,
              builder: (_, v, _) => LinearProgressIndicator(
                value: v == 0 ? null : v,
                minHeight: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
