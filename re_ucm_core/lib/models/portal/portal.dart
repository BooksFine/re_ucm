import 'package:flutter_svg/flutter_svg.dart';
import 'package:re_ucm_core/models/portal/portal_service.dart';

abstract interface class Portal {
  final String url;
  final String name;
  final String code;
  final SvgAssetLoader logo;
  PortalService get service;

  const Portal(this.url, this.name, this.code, this.logo);

  factory Portal.fromCode(String code) {
    try {
      return _portalsCodeMap[code]!;
    } catch (e) {
      throw ArgumentError('Invalid portal code');
    }
  }

  factory Portal.fromUrl(Uri uri) {
    try {
      return _portalsUrlMap[uri.origin]!;
    } catch (e) {
      throw ArgumentError('Invalid portal url');
    }
  }

  static void registerPortal(Portal portal) {
    _portalsUrlMap[portal.url] = portal;
    _portalsCodeMap[portal.code] = portal;
  }
}

final Map<String, Portal> _portalsUrlMap = {};
final Map<String, Portal> _portalsCodeMap = {};
