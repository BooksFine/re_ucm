import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/overlay_snack.dart';

Future<void> launchExternalUrl(BuildContext context, WebUri uri) async {
  try {
    var urlToLaunch = uri.uriValue;

    if (uri.scheme == 'intent') {
      final intentUrl = uri.toString();
      // Try to extract the real URL from intent:// format
      final match = RegExp(
        r'intent://(.*?)#Intent;scheme=(.*?);',
      ).firstMatch(intentUrl);
      if (match != null) {
        final hostPath = match.group(1);
        final scheme = match.group(2);
        urlToLaunch = Uri.parse('$scheme://$hostPath');
      }
    }

    final launched = await launchUrl(
      urlToLaunch,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && context.mounted) {
      overlaySnackMessage(context, 'Не удалось открыть приложение');
    }
  } catch (e) {
    if (!context.mounted) return;
    String errorMessage = e.toString();
    if (e is PlatformException && e.code == 'ACTIVITY_NOT_FOUND') {
      errorMessage = 'Приложение не установлено';
    } else {
      errorMessage = 'Ошибка при открытии ссылки: $e';
    }
    overlaySnackMessage(context, errorMessage);
  }
}
