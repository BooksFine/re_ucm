import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../core/constants.dart';
import '../../core/logger.dart';
import '../../core/navigation/router_delegate.dart';
import 'ota_repo.dart';
import 'presentation/changelog_dialog.dart';
import 'presentation/update_widget.dart';

class OTAService {
  late final OTARepo otaRepo;

  OTAService._();
  static Future<OTAService> init() async {
    var service = OTAService._();
    service.otaRepo = await OTARepoBySembast.init();
    service.update();
    return service;
  }

  String? actualVersion;

  Future<void> getActualVersion() async {
    try {
      if (actualVersion == null) {
        final dio = Dio();
        final res = await dio.get(otaVersionUrl);

        actualVersion = res.data['tag_name'];
      }
    } catch (e, trace) {
      logger.e(e, stackTrace: trace);
    }
    return;
  }

  Future<bool> getIsFirstLaunch() async =>
      appVersion != await otaRepo.getLatestLaunchVersion();

  void setLatestLaunchVersion() => otaRepo.setLatestLaunchVersion(appVersion);

  void update() async {
    await getActualVersion();

    if (actualVersion != null && actualVersion != appVersion) {
      Nav.pushBottomSheet(UpdateWidget());
    }
  }

  static void firstLaunch() async {
    var service = GetIt.I<OTAService>();
    if (await service.getIsFirstLaunch()) {
      await Nav.pushDialog((_, _, _) => const ChangelogDialog());
      service.setLatestLaunchVersion();
    }
  }
}
