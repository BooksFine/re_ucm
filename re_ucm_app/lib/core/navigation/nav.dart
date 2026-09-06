import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/models/portal.dart';

import '../logger.dart';
import 'router.dart';

BuildContext? get _context => rootNavigationKey.currentContext;

/// Фасад навигации поверх [rootNavigationKey] (исторический шим
/// совместимости удалён, канонический импорт — `core/navigation/nav.dart`).
///
/// Синхронные `go*`/`back` возвращают `bool` (`true` = успех, `false` =
/// Navigator ещё не готов — записан `logger.w`). Асинхронные `push*`
/// возвращают `Future` как раньше, но при `currentContext == null` пишут
/// `logger.w` и возвращают `null` вместо тишины.
class Nav {
  /// Nullable контекст для мест, где навигация может вызываться
  /// до готовности Navigator (холодный старт, фон).
  /// Используется чужой зоной (di.dart, share_receiver) без обхода Nav.
  static BuildContext? get contextOrNull => _context;

  static bool get canNavigate => _context != null;

  static bool _warnNull(String method) {
    logger.w('Nav.$method: Navigator context is null — navigation skipped');
    return false;
  }

  static bool back([dynamic data]) {
    final ctx = _context;
    if (ctx == null) return _warnNull('back');
    ctx.pop(data);
    return true;
  }

  static Future<Object?>? pushSettings() {
    final ctx = _context;
    if (ctx == null) {
      _warnNull('pushSettings');
      return null;
    }
    return ctx.pushNamed(RouteNames.settings);
  }

  static Future<Object?>? pushWebAuth(PortalSettingWebAuthButton field) {
    final ctx = _context;
    if (ctx == null) {
      _warnNull('pushWebAuth');
      return Future<Object?>.value(null);
    }
    return ctx.push(RoutePaths.webAuth, extra: field);
  }

  static Future<Object?>? pushDialog(RoutePageBuilder dialog) {
    final ctx = _context;
    if (ctx == null) {
      _warnNull('pushDialog');
      return null;
    }
    return ctx.push(RoutePaths.dialog, extra: dialog);
  }

  static Future<Object?>? pushBottomSheet(Widget child) {
    final ctx = _context;
    if (ctx == null) {
      _warnNull('pushBottomSheet');
      return null;
    }
    return ctx.push(RoutePaths.bottomSheet, extra: child);
  }

  static bool goBrowser(String code) {
    final ctx = _context;
    if (ctx == null) return _warnNull('goBrowser');
    ctx.goNamed(
      RouteNames.browser,
      pathParameters: {'portalCode': code},
    );
    return true;
  }

  static bool goSourceDetails(String code) {
    final ctx = _context;
    if (ctx == null) return _warnNull('goSourceDetails');
    ctx.goNamed(
      RouteNames.sourceDetail,
      pathParameters: {'portalCode': code},
    );
    return true;
  }

  static bool goSources() {
    final ctx = _context;
    if (ctx == null) return _warnNull('goSources');
    ctx.go(RoutePaths.sources);
    return true;
  }

  static bool goChangelog() {
    final ctx = _context;
    if (ctx == null) return _warnNull('goChangelog');
    ctx.goNamed(RouteNames.changelog);
    return true;
  }
}
