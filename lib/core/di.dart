import 'package:get_it/get_it.dart';
import '../features/portals/portal.dart';
import '../features/portals/portal_service.dart';
import '../features/recent_books/application/recent_books_service.dart';

final locator = GetIt.instance;

Future<void> appInit() async {
  for (var portal in Portal.values) {
    locator.registerSingleton(
      await portal.createService(),
      instanceName: portal.code,
    );
  }

  locator.registerSingleton(await RecentBooksService.init());
}
