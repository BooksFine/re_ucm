import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/models/portal.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../features/browser/browser.dart';
import '../../features/changelog/changelog_page.dart';
import '../../features/home/home_page.dart';
import '../../features/portals/presentation/settings/web_auth_page.dart';
import '../../features/portals/presentation/source_detail_page.dart';
import '../../features/portals/presentation/sources_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import 'dialog_page.dart';
import 'error_page.dart';
import 'modal_bottom_sheet_page.dart';
import 'shell_route/navigator_container.dart';

final rootNavigationKey = GlobalKey<NavigatorState>();

/// Имена роутов — вместо строковых литералов по коду.
abstract final class RouteNames {
  static const settings = 'Settings';
  static const changelog = 'Changelog';
  static const browser = 'Browser';
  static const sourceDetail = 'SourceDetail';
  static const notFound = 'NotFound';
}

/// Пути роутов верхнего уровня.
abstract final class RoutePaths {
  static const dialog = '/dialog';
  static const webAuth = '/webauth';
  static const bottomSheet = '/bottomsheet';
  static const settingsModal = '/settings_modal';
  static const sources = '/sources';
  static const notFound = '/404';
}

GoRouter createRouter() => GoRouter(
  navigatorKey: rootNavigationKey,
  initialLocation: '/',
  errorPageBuilder: (context, state) => MaterialPage(
    key: state.pageKey,
    child: ErrorPage(
      message: state.error?.toString() ?? state.uri.toString(),
    ),
  ),
  routes: [
    GoRoute(
      path: RoutePaths.notFound,
      name: RouteNames.notFound,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: ErrorPage(
          code: state.uri.queryParameters['code'] ?? '404',
          message: state.uri.queryParameters['message'],
        ),
      ),
    ),
    GoRoute(
      path: RoutePaths.dialog,
      pageBuilder: (context, state) {
        final builder = state.extra;
        if (builder is! RoutePageBuilder) {
          return MaterialPage(
            key: state.pageKey,
            child: const ErrorPage(
              code: '400',
              message: 'Некорректные данные диалога',
            ),
          );
        }
        return DialogPage(builder: builder);
      },
    ),
    GoRoute(
      path: RoutePaths.webAuth,
      pageBuilder: (context, state) {
        final extra = state.extra;
        if (extra is! PortalSettingWebAuthButton) {
          return MaterialPage(
            key: state.pageKey,
            child: const ErrorPage(
              code: '400',
              message: 'Некорректные данные веб-авторизации',
            ),
          );
        }
        return MaterialPage(
          key: state.pageKey,
          child: WebAuthPage(field: extra),
        );
      },
    ),
    GoRoute(
      path: RoutePaths.bottomSheet,
      pageBuilder: (context, state) {
        final child = state.extra;
        if (child is! Widget) {
          return MaterialPage(
            key: state.pageKey,
            child: const ErrorPage(
              code: '400',
              message: 'Некорректные данные bottom sheet',
            ),
          );
        }
        return ModalBottomSheetPage(
          child: child,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        );
      },
    ),
    GoRoute(
      path: RoutePaths.settingsModal,
      name: RouteNames.settings,
      pageBuilder: (context, state) {
        return MaterialPage(
          key: state.pageKey,
          child: SettingsPage(),
        );
      },
    ),
    StatefulShellRoute(
      builder: (context, state, navigationShell) => navigationShell,
      navigatorContainerBuilder: (context, navigationShell, children) {
        return NavigatorContainer(
          navigationShell: navigationShell,
          children: children,
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              pageBuilder: (context, state) =>
                  const MaterialPage(child: HomePage()),
              routes: [
                GoRoute(
                  path: 'changelog',
                  name: RouteNames.changelog,
                  pageBuilder: (context, state) {
                    return MaterialPage(
                      key: state.pageKey,
                      child: const ChangelogPage(),
                    );
                  },
                ),
                GoRoute(
                  parentNavigatorKey: rootNavigationKey,
                  name: RouteNames.browser,
                  path: 'browser/:portalCode',
                  redirect: (context, state) {
                    final code = state.pathParameters['portalCode'];
                    if (code == null || PortalFactory.findByCode(code) == null) {
                      return Uri(
                        path: RoutePaths.notFound,
                        queryParameters: {
                          'code': '404',
                          'message': 'Неизвестный портал: $code',
                        },
                      ).toString();
                    }
                    return null;
                  },
                  pageBuilder: (context, state) {
                    final portal = PortalFactory.findByCode(
                      state.pathParameters['portalCode']!,
                    )!;
                    return MaterialPage(
                      key: state.pageKey,
                      child: Browser(portal: portal),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/sources',
              pageBuilder: (context, state) =>
                  const MaterialPage(child: SourcesPage()),
              routes: [
                GoRoute(
                  name: RouteNames.sourceDetail,
                  path: ':portalCode',
                  pageBuilder: (context, state) {
                    return MaterialPage(
                      key: state.pageKey,
                      child: SourceDetailPage(
                        portalCode: state.pathParameters['portalCode'] ?? '',
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              pageBuilder: (context, state) => MaterialPage(
                key: state.pageKey,
                child: SettingsPage(
                  isEmbedded: true,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
