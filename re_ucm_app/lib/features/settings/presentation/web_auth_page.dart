import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:re_ucm_core/models/portal.dart';

import '../../../core/navigation/router_delegate.dart';
import '../../common/utils/external_launcher.dart';
import '../../common/widgets/appbar.dart';

class WebAuthPage extends StatefulWidget {
  const WebAuthPage({super.key, required this.field});

  final PortalSettingWebAuthButton field;

  @override
  State<WebAuthPage> createState() => _WebAuthPageState();
}

class _WebAuthPageState extends State<WebAuthPage> {
  bool isLoading = true;
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        leading: IconButton(
          onPressed: Nav.back,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialSettings: InAppWebViewSettings(
              userAgent: widget.field.userAgent,
              useHybridComposition: false,
              useShouldOverrideUrlLoading: true,
            ),
            initialUrlRequest: URLRequest(url: WebUri(widget.field.startUrl)),
            onLoadStart: (controller, url) {
              isLoading = true;
              setState(() {});
            },
            onLoadStop: (controller, url) async {
              isLoading = false;
              setState(() {});
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final uri = navigationAction.request.url!;
              final url = uri.toString();

              if (url.startsWith(widget.field.successUrl)) {
                final cookies = await CookieManager.instance().getCookies(
                  url: uri,
                );
                final target = cookies
                    .where((c) => c.name == widget.field.cookieName)
                    .firstOrNull;
                if (target != null && mounted) {
                  Nav.back(target.value.toString());
                  return NavigationActionPolicy.CANCEL;
                }
              }

              if (uri.scheme != 'http' && uri.scheme != 'https') {
                await launchExternalUrl(context, uri);
                return NavigationActionPolicy.CANCEL;
              }

              return NavigationActionPolicy.ALLOW;
            },
            onProgressChanged: (controller, progress) {
              this.progress = progress / 100;
              setState(() {});
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
