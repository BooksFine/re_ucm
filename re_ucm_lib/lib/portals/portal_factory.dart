import 'package:re_ucm_core/models/portal.dart';

class PortalFactory {
  static final Map<String, Portal> _portalsByUrl = {};
  static final Map<String, Portal> _portalsByCode = {};

  static List<Portal> get portals => _portalsByCode.values.toList();

  // Register a portal by passing the class type
  static void registerPortal(Portal portal) {
    _portalsByUrl[portal.url] = portal;
    _portalsByCode[portal.code] = portal;
  }

  // Fetch portal from code or URL
  static Portal fromCode(String code) =>
      _portalsByCode[code] ?? (throw ArgumentError('Invalid portal code: $code'));

  static Portal fromUrl(Uri uri) =>
      _portalsByUrl[uri.origin] ?? (throw ArgumentError('Invalid portal URL: $uri'));

  static Portal fromJson(Map<String, dynamic> json) => fromCode(json['code']);
  static Map<String, dynamic> toJson(Portal portal) => {'code': portal.code};

  // Optional: Register multiple portals at once
  static void registerAll(List<Portal> portals) {
    for (var portal in portals) {
      registerPortal(portal);
    }
  }
}
