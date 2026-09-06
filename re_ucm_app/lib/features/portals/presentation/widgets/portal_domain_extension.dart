import 'package:re_ucm_core/models/portal.dart';

extension PortalDomainExtension on Portal {
  /// Extracts the readable host/domain from the portal URL.
  String get domain {
    try {
      final uri = Uri.parse(url);
      return uri.host.isNotEmpty ? uri.host : url;
    } catch (_) {
      return url;
    }
  }

  /// Whether the portal supports authentication.
  bool get hasAuth => code != 'ficbook';
}
