import 'package:re_ucm_core/models/portal.dart';

extension PortalDomainExtension on Portal {
  /// Extracts the readable host/domain from the portal URL.
  String get domain {
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    return uri.host.isNotEmpty ? uri.host : url;
  }
}
