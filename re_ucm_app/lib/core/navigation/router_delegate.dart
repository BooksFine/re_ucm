import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:re_ucm_core/models/portal.dart';
import 'router.dart';

BuildContext get _context => rootNavigationKey.currentContext!;

class Nav {
  static void back([dynamic data]) => _context.pop(data);

  static Future<Object?> pushSettings() => _context.pushNamed('Settings');

  static Future<Object?> pushWebAuth(PortalSettingWebAuthButton field) =>
      _context.push('/webauth', extra: field);

  static Future<Object?> pushDialog(RoutePageBuilder dialog) =>
      _context.push('/dialog', extra: dialog);

  static Future<Object?> pushBottomSheet(Widget child) =>
      _context.push('/bottomsheet', extra: child);

  static void book(String code, String id) =>
      _context.goNamed('Book', pathParameters: {'portalCode': code, 'id': id});

  static void bookFromBrowser(String code, String id) => _context.goNamed(
    'BookFromBrowser',
    pathParameters: {'portalCode': code, 'id': id},
  );

  static void goBrowser(String code) =>
      _context.goNamed('Browser', pathParameters: {'portalCode': code});

  static void goChangelog() => _context.goNamed('Changelog');
}
