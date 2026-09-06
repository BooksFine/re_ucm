import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/constants.dart';
import '../../core/logger.dart';
import 'ota_repo.dart';

class ReleaseAsset {
  final String name;
  final String downloadUrl;
  final int? size;

  ReleaseAsset({required this.name, required this.downloadUrl, this.size});
}

class OTAService {
  late final OTARepo otaRepo;

  OTAService._();
  static Future<OTAService> init() async {
    final service = OTAService._();
    service.otaRepo = await OTARepoBySembast.init();
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
      final isAppImage =
          Platform.environment['APPIMAGE'] != null ||
          Platform.environment['APPDIR'] != null;
      final isDebInstalled = Platform.resolvedExecutable.contains('/usr/');

      ReleaseAsset? linuxAsset;
      if (isAppImage) {
        linuxAsset = assets.cast<ReleaseAsset?>().firstWhere(
          (a) => a?.name.toLowerCase().endsWith('.appimage') ?? false,
          orElse: () => null,
        );
      } else if (isDebInstalled) {
        linuxAsset = assets.cast<ReleaseAsset?>().firstWhere(
          (a) => a?.name.toLowerCase().endsWith('.deb') ?? false,
          orElse: () => null,
        );
      }

      linuxAsset ??= assets.cast<ReleaseAsset?>().firstWhere(
        (a) => a?.name == 'ReUCM_linux_amd64.deb',
        orElse: () => assets.cast<ReleaseAsset?>().firstWhere(
          (a) => a?.name.toLowerCase().endsWith('.deb') ?? false,
          orElse: () => assets.cast<ReleaseAsset?>().firstWhere(
            (a) => a?.name.toLowerCase().endsWith('.appimage') ?? false,
            orElse: () => assets.cast<ReleaseAsset?>().firstWhere(
              (a) => a?.name.toLowerCase().endsWith('.tar.gz') ?? false,
              orElse: () => null,
            ),
          ),
        ),
      );
      return linuxAsset?.downloadUrl;
    } else if (Platform.isMacOS) {
      final macAsset = assets.cast<ReleaseAsset?>().firstWhere((a) {
        final name = a?.name.toLowerCase() ?? '';
        return name.endsWith('.dmg') || name.endsWith('.zip');
      }, orElse: () => null);
      return macAsset?.downloadUrl;
    }
    return null;
  }

  Future<bool> getIsFirstLaunch() async =>
      appVersion != await otaRepo.getLatestLaunchVersion();

  void setLatestLaunchVersion() => otaRepo.setLatestLaunchVersion(appVersion);

  /// Проверяет обновление. Возвращает true, если есть новая версия.
  /// Навигацию (показ шита) делает вызывающий код — сервис только данные.
  Future<bool> checkForUpdate() async {
    if (isAlphaFlavor) return false;
    await getActualVersion();
    return actualVersion != null && actualVersion != appVersion;
  }
}
