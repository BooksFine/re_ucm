import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/models/portal.dart';

import 'router.dart';

BuildContext? get _context => rootNavigationKey.currentContext;

class Nav {
  /// Nullable контекст для мест, где навигация может вызываться
  /// до готовности Navigator (холодный старт, фон).
  static BuildContext? get contextOrNull => _context;

  static bool get canNavigate => _context != null;

  static void back([dynamic data]) => _context?.pop(data);

  static Future<Object?>? pushSettings() => _context?.pushNamed('Settings');

  static Future<Object?>? pushWebAuth(PortalSettingWebAuthButton field) =>
      _context?.push('/webauth', extra: field);

  static Future<Object?>? pushDialog(RoutePageBuilder dialog) =>
      _context?.push('/dialog', extra: dialog);

  static Future<Object?>? pushBottomSheet(Widget child) =>
      _context?.push('/bottomsheet', extra: child);

  static void goBrowser(String code) => _context?.goNamed(
    'Browser',
    pathParameters: {'portalCode': code},
  );

  static void goSourceDetails(String code) => _context?.goNamed(
    'SourceDetail',
    pathParameters: {'portalCode': code},
  );

  static void goSources() => _context?.go('/sources');

  static void goChangelog() => _context?.goNamed('Changelog');
}
