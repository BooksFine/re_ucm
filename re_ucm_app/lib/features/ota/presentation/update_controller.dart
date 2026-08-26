import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../core/constants.dart';
import '../../../core/logger.dart';
import '../ota_service.dart';

enum UpdateState {
  idle,
  downloading,
  installing,
  completed,
  error,
}

class UpdateController {
  final OTAService service;
  UpdateController(this.service);

  String? get actualVersion => service.actualVersion;
  String get releasePageUrl => service.releasePageUrl ?? releasesUrl;

  UpdateState state = UpdateState.idle;
  double progress = 0.0;
  String? errorMessage;
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

  Future<void> downloadAndInstall(VoidCallback onUpdate) async {
    if (isDownloading) return;

    final downloadUrl = service.getPlatformDownloadUrl();
    if (downloadUrl == null) {
      await openInBrowser();
      return;
    }

    state = UpdateState.downloading;
    progress = 0.0;
    errorMessage = null;
    _cancelToken = CancelToken();
    onUpdate();

    try {
      final tempDir = await getTemporaryDirectory();
      final uri = Uri.parse(downloadUrl);
      final rawFileName =
          uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'update';
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
          if (total > 0) {
            progress = (received / total).clamp(0.0, 1.0);
          } else {
            progress = 0.0;
          }
          onUpdate();
        },
      );

      state = UpdateState.installing;
      onUpdate();

      final openResult = await OpenFile.open(filePath);
      if (openResult.type != ResultType.done) {
        logger.w('OpenFile result: ${openResult.message} (${openResult.type})');
        errorMessage = openResult.message;
        state = UpdateState.error;
      } else {
        state = UpdateState.completed;
      }
      onUpdate();
    } catch (e, trace) {
      if (CancelToken.isCancel(e as dynamic)) {
        state = UpdateState.idle;
        onUpdate();
        return;
      }
      logger.e('OTA Download Error', error: e, stackTrace: trace);
      errorMessage = 'Ошибка загрузки обновления';
      state = UpdateState.error;
      onUpdate();
    }
  }

  void cancelDownload(VoidCallback onUpdate) {
    _cancelToken?.cancel();
    state = UpdateState.idle;
    progress = 0.0;
    onUpdate();
  }
}
