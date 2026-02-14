import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:re_ucm_core/models/portal.dart';
import '../../features/book/presentation/book_page.dart';
import '../../features/browser/browser.dart';
import '../../features/changelog/changelog_page.dart';
import '../../features/home/home_page.dart';
import '../../features/portals/domain/portal_factory.dart';
import '../../features/settings/application/settings_service.cg.dart';
import '../../features/settings/presentation/settings_dialog.dart';
import '../../features/settings/presentation/web_auth_page.dart';
import '../di.dart';
import 'dialog_page.dart';
import 'modal_bottom_sheet_page.dart';

bool isLaunched = false;

final rootNavigationKey = GlobalKey<NavigatorState>();
final router = GoRouter(
  navigatorKey: rootNavigationKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/dialog',
      pageBuilder: (context, state) =>
          DialogPage(builder: state.extra as RoutePageBuilder),
    ),
    GoRoute(
      path: '/webauth',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: WebAuthPage(field: state.extra as PortalSettingWebAuthButton),
      ),
    ),
    GoRoute(
      path: '/bottomsheet',
      pageBuilder: (context, state) => ModalBottomSheetPage(
        child: state.extra as Widget,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      ),
    ),
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => const MaterialPage(child: HomePage()),
      routes: [
        GoRoute(
          path: 'settings',
          name: "Settings",
          pageBuilder: (context, state) {
            return DialogPage(
              builder: (context, first, second) {
                return SettingsDialog(service: locator());
              },
            );
          },
        ),
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
          name: 'Browser',
          path: 'browser/:portalCode',
          pageBuilder: (context, state) {
            return MaterialPage(
              key: state.pageKey,
              child: Browser(
                portal: PortalFactory.fromCode(
                  state.pathParameters['portalCode']!,
                ),
              ),
            );
          },
          routes: [
            GoRoute(
              name: 'BookFromBrowser',
              path: 'book/:id',
              pageBuilder: (context, state) {
                return MaterialPage(
                  key: state.pageKey,
                  child: BookPage(
                    id: state.pathParameters['id']!,
                    session: locator<SettingsService>().sessionByCode(
                      state.pathParameters['portalCode']!,
                    ),
                    settings: locator(),
                    recentBooksService: locator(),
                  ),
                );
              },
            ),
          ],
        ),
        GoRoute(
          name: 'Book',
          path: 'book/:portalCode/:id',
          pageBuilder: (context, state) {
            return MaterialPage(
              key: state.pageKey,
              child: BookPage(
                id: state.pathParameters['id']!,
                session: locator<SettingsService>().sessionByCode(
                  state.pathParameters['portalCode']!,
                ),
                settings: locator(),
                recentBooksService: locator(),
              ),
            );
          },
        ),
      ],
    ),
  ],
);
