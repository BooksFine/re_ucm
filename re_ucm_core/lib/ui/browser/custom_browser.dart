import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class CustomBrowser extends StatefulWidget {
  const CustomBrowser({
    super.key,
    required this.url,
    required this.shouldOverrideUrlLoading,
    this.userAgent,
  });

  final String url;
  final NavigationActionPolicy Function(NavigationAction navigationAction)
      shouldOverrideUrlLoading;

  final String? userAgent;

  @override
  State<CustomBrowser> createState() => _CustomBrowserState();
}

class _CustomBrowserState extends State<CustomBrowser> {
  double progress = 0;
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: Navigator.of(context).pop,
          icon: Icon(Icons.arrow_back_ios_new),
        ),
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
                useHybridComposition: false,
                userAgent: widget.userAgent,
              ),
              initialUrlRequest: URLRequest(
                url: WebUri(widget.url),
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
                return widget.shouldOverrideUrlLoading(navigationAction);
              },
            ),
          ),
        ],
      ),
    );
  }
}
