import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/book/presentation/book_page.dart';
import '../../features/browser/browser.dart';
import '../../features/browser/custom_browser.dart';
import '../../features/changelog/changelog_page.dart';
import '../../features/home/home_page.dart';
import '../../features/portals/portal.dart';
import 'dialog_page.dart';

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
      path: '/',
      pageBuilder: (context, state) => const MaterialPage(child: HomePage()),
      routes: [
        GoRoute(
          name: 'CustomBrowser',
          path: 'browser',
          pageBuilder: (context, state) {
            var extra = state.extra as CustomBrowserParams;
            return CupertinoPage(
              key: state.pageKey,
              child: CustomBrowser(params: extra),
            );
          },
        ),
        GoRoute(
          path: 'changelog',
          name: 'Changelog',
          pageBuilder: (context, state) {
            return CupertinoPage(
              key: state.pageKey,
              child: const ChangelogPage(),
            );
          },
        ),
        GoRoute(
          name: 'Browser',
          path: 'browser/:portalCode',
          pageBuilder: (context, state) {
            return CupertinoPage(
              key: state.pageKey,
              child: Browser(
                portal: Portal.fromCode(state.pathParameters['portalCode']!),
              ),
            );
          },
          routes: [
            GoRoute(
              name: 'BookFromBrowser',
              path: 'book/:id',
              pageBuilder: (context, state) {
                return CupertinoPage(
                  key: state.pageKey,
                  child: BookPage(
                    id: state.pathParameters['id']!,
                    portal:
                        Portal.fromCode(state.pathParameters['portalCode']!),
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
            return CupertinoPage(
              key: state.pageKey,
              child: BookPage(
                id: state.pathParameters['id']!,
                portal: Portal.fromCode(state.pathParameters['portalCode']!),
              ),
            );
          },
        ),
      ],
    ),
  ],
);
