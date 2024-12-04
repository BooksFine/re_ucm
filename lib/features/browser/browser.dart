import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:re_ucm_core/models/portal.dart';
import '../../core/navigation/router_delegate.dart';
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
      body: Column(
        children: [
          AnimatedSize(
            alignment: Alignment.topCenter,
            duration: Durations.short4,
            child: isLoading
                ? TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: progress),
                    duration: Durations.short4,
                    builder: (_, v, __) => LinearProgressIndicator(
                      value: v == 0 ? null : v,
                      minHeight: 3,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: InAppWebView(
              initialSettings: InAppWebViewSettings(
                useShouldOverrideUrlLoading: true,
                useHybridComposition: true,
              ),
              onPermissionRequest: (controller, request) async {
                return PermissionResponse(
                    resources: request.resources,
                    action: PermissionResponseAction.GRANT);
              },
              initialUrlRequest: URLRequest(
                url: WebUri(widget.portal.url),
              ),
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
                try {
                  final bookId = widget.portal.service.getIdFromUrl(uri);
                  Nav.bookFromBrowser(widget.portal.code, bookId);
                  return NavigationActionPolicy.CANCEL;
                } catch (e) {
                  return NavigationActionPolicy.ALLOW;
                }
              },
              onUpdateVisitedHistory: (controller, url, isReload) {
                if (isReload == true) return;
                try {
                  final bookId =
                      widget.portal.service.getIdFromUrl(url!.uriValue);
                  Nav.bookFromBrowser(widget.portal.code, bookId);
                } catch (e) {
                  {}
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
