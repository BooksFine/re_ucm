import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../core/navigation/router_delegate.dart';
import '../common/widgets/appbar.dart';
import '../settings/presentation/settings_dialog.dart';

class CustomBrowserParams {
  final String url;
  final NavigationActionPolicy Function(NavigationAction navigationAction)
      shouldOverrideUrlLoading;

  final String? userAgent;

  CustomBrowserParams({
    required this.url,
    required this.shouldOverrideUrlLoading,
    this.userAgent,
  });
}

class CustomBrowser extends StatefulWidget {
  const CustomBrowser({
    super.key,
    required this.params,
  });

  final CustomBrowserParams params;

  @override
  State<CustomBrowser> createState() => _CustomBrowserState();
}

class _CustomBrowserState extends State<CustomBrowser> {
  double progress = 0;
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
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
                useHybridComposition: false,
                userAgent: widget.params.userAgent,
              ),
              initialUrlRequest: URLRequest(
                url: WebUri(widget.params.url),
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
                return widget.params.shouldOverrideUrlLoading(navigationAction);
              },
            ),
          ),
        ],
      ),
    );
  }
}
