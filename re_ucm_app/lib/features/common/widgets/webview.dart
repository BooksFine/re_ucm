import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../utils/external_launcher.dart';

class AppWebView extends StatefulWidget {
  const AppWebView({
    super.key,
    required this.initialUrl,
    this.userAgent,
    this.onWebViewCreated,
    this.shouldOverrideUrlLoading,
    this.onUpdateVisitedHistory,
    this.onPermissionRequest,
    this.onLoadStart,
    this.onLoadStop,
    this.initialSettings,
    this.extraChildren = const [],
  });

  final WebUri initialUrl;
  final String? userAgent;
  final InAppWebViewSettings? initialSettings;
  final List<Widget> extraChildren;

  final void Function(InAppWebViewController controller)? onWebViewCreated;
  final Future<NavigationActionPolicy?> Function(
    InAppWebViewController controller,
    NavigationAction navigationAction,
  )?
  shouldOverrideUrlLoading;
  final void Function(
    InAppWebViewController controller,
    WebUri? url,
    bool? isReload,
  )?
  onUpdateVisitedHistory;
  final Future<PermissionResponse?> Function(
    InAppWebViewController controller,
    PermissionRequest permissionRequest,
  )?
  onPermissionRequest;
  final void Function(InAppWebViewController controller, WebUri? url)?
  onLoadStart;
  final void Function(InAppWebViewController controller, WebUri? url)?
  onLoadStop;

  @override
  State<AppWebView> createState() => _AppWebViewState();
}

class _AppWebViewState extends State<AppWebView> {
  bool isLoading = true;
  double progress = 0;
  bool isPageOpened = false;

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
        if (isPageOpened)
          InAppWebView(
            initialSettings:
                widget.initialSettings ??
                InAppWebViewSettings(
                  useShouldOverrideUrlLoading: true,
                  useHybridComposition: false,
                  userAgent: widget.userAgent,
                ),
            onWebViewCreated: widget.onWebViewCreated,
            onPermissionRequest: widget.onPermissionRequest,
            initialUrlRequest: URLRequest(url: widget.initialUrl),
            onLoadStart: (controller, url) {
              setState(() => isLoading = true);
              widget.onLoadStart?.call(controller, url);
            },
            onLoadStop: (controller, url) {
              setState(() => isLoading = false);
              widget.onLoadStop?.call(controller, url);
            },
            onProgressChanged: (controller, progress) {
              setState(() => this.progress = progress / 100);
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final uri = navigationAction.request.url!;
              if (uri.scheme != 'http' && uri.scheme != 'https') {
                await launchExternalUrl(context, uri);
                return NavigationActionPolicy.CANCEL;
              }
              if (widget.shouldOverrideUrlLoading != null) {
                return await widget.shouldOverrideUrlLoading!(
                  controller,
                  navigationAction,
                );
              }
              return NavigationActionPolicy.ALLOW;
            },
            onUpdateVisitedHistory: widget.onUpdateVisitedHistory,
          ),
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
