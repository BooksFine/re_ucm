import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:ota_update_fork/ota_update_fork.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../core/constants.dart';
import '../../../core/logger.dart';
import '../ota_service.dart';

class UpdateController {
  late final OTAService service;
  UpdateController() {
    service = GetIt.I<OTAService>();
  }

  String? get actualVersion => service.actualVersion;

  Stream<double>? progressStream;

  updateApp(VoidCallback callback) {
    try {
      if (kIsWeb || !Platform.isAndroid) return launchUrlString(releasesUrl);

      progressStream = OtaUpdate()
          .execute(otaHost, destinationFilename: 'reucm-$actualVersion.apk')
          .map(
            (e) => switch (e.status) {
              OtaStatus.DOWNLOADING => double.parse(e.value!),
              _ => () {
                  progressStream = null;
                  callback();
                  return 100.0;
                }()
            },
          );
      callback();
    } catch (e, trace) {
      logger.e('OTA Error', error: e, stackTrace: trace);
    }
  }
}
