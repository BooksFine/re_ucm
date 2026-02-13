import 'package:re_ucm_core/models/portal.dart';
import 'package:re_ucm_core/models/portal/portal_settings.dart';

import '../../portals/domain/portal_factory.dart';
import '../data/settings_storage.dart';
import '../domain/path_template.cg.dart';

class SettingsService {
  SettingsService._();

  final List<Portal<PortalSettings>> portals = PortalFactory.portals;
  late final SettingsStorage storage;

  static Future<SettingsService> init() async {
    final service = SettingsService._();
    service.storage = await SettingsStorageSembast.init();
    await service.loadSettings();
    return service;
  }

  late PathTemplate _downloadPathTemplate;
  PathTemplate get downloadPathTemplate => _downloadPathTemplate;
  late String _authorsPathSeparator;
  String get authorsPathSeparator => _authorsPathSeparator;
  late Map<String, Map<String, Object?>> _portalSettingsByCode;

  Future<void> loadSettings() async {
    _downloadPathTemplate = await storage.getDownloadPathTemplate();
    _authorsPathSeparator = await storage.getAuthorsPathSeparator();
    _portalSettingsByCode = await storage.getPortalsSettings();
  }

  void updateDownloadPathTemplate(PathTemplate template) {
    _downloadPathTemplate = template;
    storage.setDownloadPathTemplate(template);
  }

  void updateAuthorsPathSeparator(String separator) {
    _authorsPathSeparator = separator;
    storage.setAuthorsPathSeparator(separator);
  }

  T getPortalSettings<T extends PortalSettings>(Portal<T> portal) {
    final settings = portal.service.settingsFromJson(
      _portalSettingsByCode[portal.code],
    );
    return settings;
  }

  Future<void> replacePortalSettings<T extends PortalSettings>(
    Portal<T> portal,
    T settings,
  ) async {
    _portalSettingsByCode[portal.code] = settings.toJson();
    await storage.setPortalSettings(
      portal.code,
      _portalSettingsByCode[portal.code]!,
    );
  }
}
