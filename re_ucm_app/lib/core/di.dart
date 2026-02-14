import 'package:flutter/widgets.dart';
import 'package:re_ucm_author_today/re_ucm_author_today.dart';

import '../features/ota/ota_service.dart';
import '../features/portals/domain/portal_factory.dart';
import '../features/recent_books/application/recent_books_service.dart';
import '../features/settings/application/settings_service.cg.dart';

class AppDependencies extends InheritedWidget {
  final OTAService otaService;
  final RecentBooksService recentBooksService;
  final SettingsService settingsService;

  const AppDependencies({
    super.key,
    required super.child,
    required this.otaService,
    required this.recentBooksService,
    required this.settingsService,
  });

  static AppDependencies of(BuildContext context) {
    final result = context
        .dependOnInheritedWidgetOfExactType<AppDependencies>();
    assert(result != null, 'No AppDependencies found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AppDependencies oldWidget) => false;

  static Future<AppDependencies> init({required Widget child}) async {
    PortalFactory.registerAll([AuthorToday()]);

    final otaService = await OTAService.init();
    final recentBooksService = await RecentBooksService.init();
    final settingsService = await SettingsService.init();

    return AppDependencies(
      otaService: otaService,
      recentBooksService: recentBooksService,
      settingsService: settingsService,
      child: child,
    );
  }
}
