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
import '../di.dart';
import 'dialog_page.dart';
import 'modal_bottom_sheet_page.dart';
import 'shell_route/navigator_container.dart';

final rootNavigationKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AppDependencies deps) => GoRouter(
  navigatorKey: rootNavigationKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/dialog',
      pageBuilder: (context, state) {
        final builder = state.extra;
        if (builder is! RoutePageBuilder) {
          return const MaterialPage(child: SizedBox.shrink());
        }
        return DialogPage(builder: builder);
      },
    ),
    GoRoute(
      path: '/webauth',
      pageBuilder: (context, state) {
        final extra = state.extra;
        if (extra is! PortalSettingWebAuthButton) {
          return const MaterialPage(child: SizedBox.shrink());
        }
        return MaterialPage(
          key: state.pageKey,
          child: WebAuthPage(field: extra),
        );
      },
    ),
    GoRoute(
      path: '/bottomsheet',
      pageBuilder: (context, state) {
        final child = state.extra;
        if (child is! Widget) {
          return const MaterialPage(child: SizedBox.shrink());
        }
        return ModalBottomSheetPage(
          child: child,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        );
      },
    ),
    GoRoute(
      path: '/settings_modal',
      name: "Settings",
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
                  name: 'Changelog',
                  pageBuilder: (context, state) {
                    return MaterialPage(
                      key: state.pageKey,
                      child: const ChangelogPage(),
                    );
                  },
                ),
                GoRoute(
                  parentNavigatorKey: rootNavigationKey,
                  name: 'Browser',
                  path: 'browser/:portalCode',
                  pageBuilder: (context, state) {
                    final code = state.pathParameters['portalCode'];
                    final portal = code != null
                        ? PortalFactory.portals.cast<Portal?>().firstWhere(
                              (p) => p!.code == code,
                              orElse: () => null,
                            )
                        : null;
                    if (portal == null) {
                      return const MaterialPage(child: SizedBox.shrink());
                    }
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
                  name: 'SourceDetail',
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
