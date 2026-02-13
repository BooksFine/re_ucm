import 'package:get_it/get_it.dart';
import 'package:re_ucm_author_today/re_ucm_author_today.dart';

import '../features/ota/ota_service.dart';
import '../features/portals/domain/portal_factory.dart';
import '../features/recent_books/application/recent_books_service.dart';
import '../features/settings/application/settings_service.cg.dart';

final locator = GetIt.instance;

Future<void> appInit() async {
  PortalFactory.registerAll([AuthorToday()]);

  locator.registerSingleton(await OTAService.init());

  locator.registerSingleton(await RecentBooksService.init());

  locator.registerSingleton(await SettingsService.init());
}
