import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/models/portal.dart';
import 'package:webview_all/webview_all.dart';

import '../../../../core/navigation/router_delegate.dart';
import '../../../common/widgets/appbar.dart';
import '../../../common/widgets/webview.dart';

class WebAuthPage extends StatelessWidget {
  const WebAuthPage({super.key, required this.field});

  final PortalSettingWebAuthButton field;

  Future<bool> _tryExtractAndPop(BuildContext context, Uri uri) async {
    final cookie = await _extractTargetCookie(uri);
    if (cookie != null && context.mounted) {
      Nav.back(cookie);
      return true;
    }
    return false;
  }

  Future<String?> _extractTargetCookie(Uri uri) async {
    final cookieManager = WebViewCookieManager();

    String? findInCookies(List cookies) {
      for (final c in cookies) {
        if (c.name.toString().toLowerCase() == field.cookieName.toLowerCase() &&
            c.value.toString().isNotEmpty) {
          return c.value.toString();
        }
      }
      return null;
    }

    final cookies = await cookieManager.getCookies(domain: uri);
    final value = findInCookies(cookies);
    if (value != null) return value;

    final hostParts = uri.host.split('.');
    if (hostParts.length > 2) {
      final rootHost = hostParts.sublist(hostParts.length - 2).join('.');
      final rootUri = uri.replace(host: rootHost);
      final rootCookies = await cookieManager.getCookies(domain: rootUri);
      final rootValue = findInCookies(rootCookies);
      if (rootValue != null) return rootValue;
    }

    return null;
  }

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
        onUpdateVisitedHistory: (controller, uri) async {
          if (uri != null && uri.toString().startsWith(field.successUrl)) {
            await _tryExtractAndPop(context, uri);
          }
        },
        shouldOverrideUrlLoading: (controller, request) async {
          final url = request.url;
          if (url.startsWith(field.successUrl)) {
            final handled = await _tryExtractAndPop(context, Uri.parse(url));
            if (handled) {
              return NavigationDecision.prevent;
            }
          }
          return NavigationDecision.navigate;
        },
      ),
    );
  }
}
