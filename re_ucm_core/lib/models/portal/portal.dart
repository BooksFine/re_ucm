part of '../portal.dart';

abstract interface class Portal {
  String get url;
  String get name;
  String get code;
  SvgAssetLoader get logo;
  PortalService get service;

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
