import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../core/constants.dart';
import '../../../core/logger.dart';
import '../ota_service.dart';

enum UpdateState { idle, downloading, installing, completed, error }

class UpdateController {
  final OTAService service;
  UpdateController(this.service);

  String? get actualVersion => service.actualVersion;
  String get releasePageUrl => service.releasePageUrl ?? releasesUrl;

  final Observable<UpdateState> _state = Observable(UpdateState.idle);
  UpdateState get state => _state.value;

  final Observable<double> _progress = Observable(0.0);
  double get progress => _progress.value;

  final Observable<int> _recievedBytes = Observable(0);
  int get recievedBytes => _recievedBytes.value;

  final Observable<int> _totalBytes = Observable(0);
  int get totalBytes => _totalBytes.value;

  final Observable<String?> _errorMessage = Observable(null);
  String? get errorMessage => _errorMessage.value;

  CancelToken? _cancelToken;

  bool get isDownloading => state == UpdateState.downloading;

  Future<bool> openInBrowser() async {
    try {
      return await launchUrlString(
        releasePageUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (e, trace) {
      logger.e('OTA Browser Error', error: e, stackTrace: trace);
      return false;
    }
  }

  Future<void> downloadAndInstall() async {
    if (isDownloading) return;

    final downloadUrl = service.getPlatformDownloadUrl();
    if (downloadUrl == null) {
      await openInBrowser();
      return;
    }

    runInAction(() {
      _state.value = UpdateState.downloading;
      _progress.value = 0.0;
      _recievedBytes.value = 0;
      _totalBytes.value = 0;
      _errorMessage.value = null;
      _cancelToken = CancelToken();
    });

    try {
      final Directory tempDir;
      if (Platform.isAndroid) {
        final extDirs = await getExternalCacheDirectories();
        tempDir = (extDirs != null && extDirs.isNotEmpty)
            ? extDirs.first
            : await getTemporaryDirectory();
      } else {
        tempDir = await getTemporaryDirectory();
      }
      final uri = Uri.parse(downloadUrl);
      final rawFileName = uri.pathSegments.isNotEmpty
          ? uri.pathSegments.last
          : 'update';
      final fileName = 'ReUCM_${actualVersion ?? "latest"}_$rawFileName';
      final filePath = '${tempDir.path}/$fileName';

      final file = File(filePath);
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {}
      }

      final dio = Dio();
      await dio.download(
        downloadUrl,
        filePath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          runInAction(() {
            _recievedBytes.value = received;
            _totalBytes.value = total;
            _progress.value = total > 0
                ? (received / total).clamp(0.0, 1.0)
                : 0.0;
          });
        },
      );

      runInAction(() => _state.value = UpdateState.installing);

      if (Platform.isLinux) {
        try {
          await Process.run('chmod', ['+x', filePath]);
        } catch (e) {
          logger.w('Failed to set executable permissions: $e');
        }
      }

      if (Platform.isAndroid) {
        try {
          final status = await Permission.requestInstallPackages.status;
          if (!status.isGranted) {
            await Permission.requestInstallPackages.request();
          }
        } catch (e) {
          logger.w('Failed to request install packages permission: $e');
        }
      }

      final openResult = await OpenFile.open(
        filePath,
        type: Platform.isAndroid
            ? 'application/vnd.android.package-archive'
            : null,
      );
      runInAction(() {
        if (openResult.type != ResultType.done) {
          logger.w(
              'OpenFile result: ${openResult.message} (${openResult.type})');
          _errorMessage.value = openResult.message;
          _state.value = UpdateState.error;
        } else {
          _state.value = UpdateState.completed;
        }
      });
    } catch (e, trace) {
      if (CancelToken.isCancel(e as dynamic)) {
        runInAction(() => _state.value = UpdateState.idle);
        return;
      }
      logger.e('OTA Download Error', error: e, stackTrace: trace);
      runInAction(() {
        _errorMessage.value = 'Ошибка загрузки обновления';
        _state.value = UpdateState.error;
      });
    }
  }

  void cancelDownload() {
    _cancelToken?.cancel();
    runInAction(() {
      _state.value = UpdateState.idle;
      _progress.value = 0.0;
    });
  }
}
