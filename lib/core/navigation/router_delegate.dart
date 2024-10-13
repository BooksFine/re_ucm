import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'router.dart';

BuildContext get _context => rootNavigationKey.currentContext!;

class Nav {
  static back([dynamic data]) => _context.pop(data);

  static pushDialog(RoutePageBuilder dialog) =>
      _context.push('/dialog', extra: dialog);

  static book(String code, String id) =>
      _context.goNamed('Book', pathParameters: {'portalCode': code, 'id': id});

  static bookFromBrowser(String code, String id) =>
      _context.goNamed('BookFromBrowser',
          pathParameters: {'portalCode': code, 'id': id});

  static goBrowser(String code) =>
      _context.goNamed('Browser', pathParameters: {'portalCode': code});

  static goChangelog() => _context.goNamed('Changelog');
}
