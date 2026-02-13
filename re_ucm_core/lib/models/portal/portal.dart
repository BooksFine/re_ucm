part of '../portal.dart';

abstract interface class Portal<T extends PortalSettings> {
  String get url;
  String get name;
  String get code;
  PortalLogo get logo;
  PortalService<T> get service;
}

final class PortalLogo {
  const PortalLogo({required this.assetPath, this.packageName});

  final String assetPath;
  final String? packageName;
}
