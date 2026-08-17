import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../core/constants.dart';
import '../../../core/logger.dart';
import '../ota_service.dart';

class UpdateController {
  final OTAService service;
  UpdateController(this.service);

  String? get actualVersion => service.actualVersion;

  Stream<double>? progressStream;

  Future<bool> updateApp(VoidCallback callback) async {
    try {
      return await launchUrlString(releasesUrl);
    } catch (e, trace) {
      logger.e('OTA Error', error: e, stackTrace: trace);
      return false;
    }
  }
}
