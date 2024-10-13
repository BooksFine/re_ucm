part of '../portal.dart';

abstract interface class Portal {
  String get url;
  String get name;
  String get code;
  SvgAssetLoader get logo;
  PortalService get service;
}
