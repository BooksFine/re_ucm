import 'package:flutter/material.dart';
import 'package:re_ucm_core/models/portal.dart';
import 'package:webview_all/webview_all.dart';

import '../../../../core/navigation/router_delegate.dart';
import '../../../common/widgets/appbar.dart';
import '../../../common/widgets/webview.dart';

class WebAuthPage extends StatelessWidget {
  const WebAuthPage({super.key, required this.field});

  final PortalSettingWebAuthButton field;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        leading: IconButton(
          onPressed: Nav.back,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: AppWebView(
        initialUrl: Uri.parse(field.startUrl),
        userAgent: field.userAgent,
        shouldOverrideUrlLoading: (controller, request) async {
          final url = request.url;

          if (url.startsWith(field.successUrl)) {
            final uri = Uri.parse(url);
            final cookies =
                await WebViewCookieManager().getCookies(domain: uri);
            final target =
                cookies.where((c) => c.name == field.cookieName).firstOrNull;
            if (target != null && context.mounted) {
              Nav.back(target.value);
              return NavigationDecision.prevent;
            }
          }

          return NavigationDecision.navigate;
        },
      ),
    );
  }
}
