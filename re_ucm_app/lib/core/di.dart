import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:re_ucm_author_today/re_ucm_author_today.dart';
import 'package:re_ucm_ficbook/re_ucm_ficbook.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';
import 'package:re_ucm_litres/re_ucm_litres.dart';
import 'package:sembast/sembast_io.dart';

import '../features/downloads/domain/downloads_service.cg.dart';
import '../features/downloads/presentation/download_modal.dart';
import '../features/ota/ota_service.dart';
import '../features/settings/presentation/settings_controller.cg.dart';
import 'navigation/router.dart';

class AppDependencies extends InheritedWidget {
  final OTAService otaService;
  final RecentBooksService recentBooksService;
  final SettingsService settingsService;
  final SettingsController settingsController;
  final DownloadsService downloadsService;

  const AppDependencies({
    super.key,
    required super.child,
    required this.otaService,
    required this.recentBooksService,
    required this.settingsService,
    required this.settingsController,
    required this.downloadsService,
  });

  static AppDependencies of(BuildContext context) {
    final result = context.getInheritedWidgetOfExactType<AppDependencies>();
    assert(result != null, 'No AppDependencies found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AppDependencies oldWidget) => false;

  static Future<AppDependencies> init({required Widget child}) async {
    disableSembastCooperator();

    PortalFactory.registerAll([AuthorToday(), Ficbook(), Litres()]);

    final otaService = await OTAService.init();
    final dir = await getApplicationSupportDirectory();
    final recentBooksService = await RecentBooksService.init(dir.path);
    final settingsService = await SettingsService.init(dir.path);
    final downloadsService = DownloadsService(
      settings: settingsService,
      recentBooksService: recentBooksService,
    );

    downloadsService.onTaskCompletedGlobal = (task) {
      if (task.showResultOnComplete) {
        final ctx = rootNavigationKey.currentContext;
        if (ctx != null) {
          showDownloadModalForTask(ctx, task);
        }
      }
    };

    enableSembastCooperator();

    final settingsController = SettingsController(service: settingsService);

    return AppDependencies(
      otaService: otaService,
      recentBooksService: recentBooksService,
      settingsService: settingsService,
      settingsController: settingsController,
      downloadsService: downloadsService,
      child: child,
    );
  }
}
