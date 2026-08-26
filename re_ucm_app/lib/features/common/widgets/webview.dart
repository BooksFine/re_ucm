import 'package:flutter/material.dart';
import 'package:webview_all/webview_all.dart';

import '../utils/external_launcher.dart';

class AppWebView extends StatefulWidget {
  const AppWebView({
    super.key,
    required this.initialUrl,
    this.userAgent,
    this.onWebViewCreated,
    this.shouldOverrideUrlLoading,
    this.onUpdateVisitedHistory,
    this.onLoadStart,
    this.onLoadStop,
    this.extraChildren = const [],
  });

  final Uri initialUrl;
  final String? userAgent;
  final List<Widget> extraChildren;

  final void Function(WebViewController controller)? onWebViewCreated;
  final Future<NavigationDecision> Function(
    WebViewController controller,
    NavigationRequest request,
  )?
  shouldOverrideUrlLoading;
  final void Function(
    WebViewController controller,
    Uri? url,
  )?
  onUpdateVisitedHistory;
  final void Function(WebViewController controller, Uri? url)? onLoadStart;
  final void Function(WebViewController controller, Uri? url)? onLoadStop;

  @override
  State<AppWebView> createState() => _AppWebViewState();
}

class _AppWebViewState extends State<AppWebView> {
  late final WebViewController controller;
  bool isLoading = true;
  double progress = 0;
  bool isPageOpened = false;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (mounted) setState(() => isLoading = true);
            widget.onLoadStart?.call(controller, Uri.tryParse(url));
          },
          onPageFinished: (url) {
            if (mounted) setState(() => isLoading = false);
            final uri = Uri.tryParse(url);
            widget.onLoadStop?.call(controller, uri);
            widget.onUpdateVisitedHistory?.call(controller, uri);
          },
          onProgress: (progress) {
            if (mounted) {
              setState(() => this.progress = progress / 100);
            }
          },
          onUrlChange: (change) {
            if (change.url != null) {
              widget.onUpdateVisitedHistory?.call(
                controller,
                Uri.tryParse(change.url!),
              );
            }
          },
          onNavigationRequest: (request) async {
            final uri = Uri.parse(request.url);
            if (uri.scheme != 'http' && uri.scheme != 'https') {
              if (mounted) {
                await launchExternalUrl(context, uri);
              }
              return NavigationDecision.prevent;
            }
            if (widget.shouldOverrideUrlLoading != null) {
              return await widget.shouldOverrideUrlLoading!(
                controller,
                request,
              );
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    if (widget.userAgent != null) {
      controller.setUserAgent(widget.userAgent);
    }

    controller.loadRequest(widget.initialUrl);
    widget.onWebViewCreated?.call(controller);
  }

  @override
  void didChangeDependencies() {
    if (isPageOpened) return;

    final route = ModalRoute.of(context);
    Future.delayed(route?.transitionDuration ?? Durations.short4, () {
      if (mounted) {
        setState(() {
          isPageOpened = true;
        });
      }
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ...widget.extraChildren,
        if (isPageOpened) WebViewWidget(controller: controller),
        AnimatedOpacity(
          duration: Durations.medium2,
          opacity: isLoading ? 1 : 0,
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: progress),
            duration: Durations.short4,
            builder: (_, v, _) =>
                LinearProgressIndicator(value: v == 0 ? null : v, minHeight: 3),
          ),
        ),
      ],
    );
  }
}
