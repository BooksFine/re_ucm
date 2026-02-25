import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:re_ucm_core/models/portal.dart';

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
        initialUrl: WebUri(field.startUrl),
        userAgent: field.userAgent,
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          final uri = navigationAction.request.url!;
          final url = uri.toString();

          if (url.startsWith(field.successUrl)) {
            final cookies = await CookieManager.instance().getCookies(url: uri);
            final target = cookies
                .where((c) => c.name == field.cookieName)
                .firstOrNull;
            if (target != null && context.mounted) {
              Nav.back(target.value.toString());
              return NavigationActionPolicy.CANCEL;
            }
          }

          return NavigationActionPolicy.ALLOW;
        },
      ),
    );
  }
}
