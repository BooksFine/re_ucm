import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/constants.dart';
import '../../core/logger.dart';
import '../../core/navigation/router_delegate.dart';
import 'ota_repo.dart';
import 'presentation/changelog_dialog.dart';
import 'presentation/update_widget.dart';

class ReleaseAsset {
  final String name;
  final String downloadUrl;
  final int? size;

  ReleaseAsset({
    required this.name,
    required this.downloadUrl,
    this.size,
  });
}

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
  String? releasePageUrl;
  final List<ReleaseAsset> assets = [];

  Future<void> getActualVersion() async {
    try {
      if (actualVersion == null) {
        final dio = Dio();
        final res = await dio.get(otaVersionUrl);

        if (res.data is Map) {
          final data = res.data as Map<String, dynamic>;
          actualVersion = data['tag_name'] as String?;
          releasePageUrl = data['html_url'] as String?;

          assets.clear();
          final rawAssets = data['assets'];
          if (rawAssets is List) {
            for (final asset in rawAssets) {
              if (asset is Map) {
                final name = asset['name'] as String?;
                final downloadUrl = asset['browser_download_url'] as String?;
                final size = asset['size'] as int?;
                if (name != null && downloadUrl != null) {
                  assets.add(
                    ReleaseAsset(
                      name: name,
                      downloadUrl: downloadUrl,
                      size: size,
                    ),
                  );
                }
              }
            }
          }
        }
      }
    } catch (e, trace) {
      logger.e(e, stackTrace: trace);
    }
  }

  String? getPlatformDownloadUrl() {
    if (Platform.isAndroid) {
      final apkAsset = assets.cast<ReleaseAsset?>().firstWhere(
            (a) => a?.name == 'ReUCM_android_arm64-v8a.apk',
            orElse: () => assets.cast<ReleaseAsset?>().firstWhere(
                  (a) => a?.name == 'ReUCM_android.apk',
                  orElse: () => assets.cast<ReleaseAsset?>().firstWhere(
                        (a) => a?.name.toLowerCase().endsWith('.apk') ?? false,
                        orElse: () => null,
                      ),
                ),
          );
      return apkAsset?.downloadUrl ?? otaHost;
    } else if (Platform.isWindows) {
      final exeAsset = assets.cast<ReleaseAsset?>().firstWhere(
            (a) => a?.name == 'ReUCM_windows.exe',
            orElse: () => assets.cast<ReleaseAsset?>().firstWhere(
                  (a) => a?.name.toLowerCase().endsWith('.exe') ?? false,
                  orElse: () => null,
                ),
          );
      return exeAsset?.downloadUrl ?? windowsOTAHost;
    } else if (Platform.isLinux) {
      final linuxAsset = assets.cast<ReleaseAsset?>().firstWhere(
            (a) {
              final name = a?.name.toLowerCase() ?? '';
              return name.endsWith('.deb') ||
                  name.endsWith('.appimage') ||
                  name.endsWith('.tar.gz');
            },
            orElse: () => null,
          );
      return linuxAsset?.downloadUrl;
    } else if (Platform.isMacOS) {
      final macAsset = assets.cast<ReleaseAsset?>().firstWhere(
            (a) {
              final name = a?.name.toLowerCase() ?? '';
              return name.endsWith('.dmg') || name.endsWith('.zip');
            },
            orElse: () => null,
          );
      return macAsset?.downloadUrl;
    }
    return null;
  }

  Future<bool> getIsFirstLaunch() async =>
      appVersion != await otaRepo.getLatestLaunchVersion();

  void setLatestLaunchVersion() => otaRepo.setLatestLaunchVersion(appVersion);

  void update() async {
    if (isAlphaFlavor) return;
    await getActualVersion();

    if (actualVersion != null && actualVersion != appVersion) {
      Nav.pushBottomSheet(UpdateWidget());
    }
  }

  static void firstLaunch(OTAService service) async {
    if (await service.getIsFirstLaunch()) {
      await Nav.pushDialog((_, _, _) => const ChangelogDialog());
      service.setLatestLaunchVersion();
    }
  }
}
