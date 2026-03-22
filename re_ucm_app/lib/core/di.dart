import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:re_ucm_author_today/re_ucm_author_today.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';
import 'package:sembast/sembast_io.dart';

import '../features/ota/ota_service.dart';

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
    disableSembastCooperator();

    PortalFactory.registerAll([AuthorToday()]);

    final otaService = await OTAService.init();
    final dir = await getApplicationSupportDirectory();
    final recentBooksService = await RecentBooksService.init(dir.path);
    final settingsService = await SettingsService.init(dir.path);

    enableSembastCooperator();

    return AppDependencies(
      otaService: otaService,
      recentBooksService: recentBooksService,
      settingsService: settingsService,
      child: child,
    );
  }
}
