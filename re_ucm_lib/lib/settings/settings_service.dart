import '../portals/portal_session.cg.dart';
import '../portals/portal_factory.dart';
import 'data/settings_storage.dart';
import 'data/settings_storage_sembast.dart';
import 'domain/path_template.cg.dart';

class SettingsService {
  SettingsService._();

  late final SettingsStorage storage;
  late final List<PortalSession> _sessions;

  static Future<SettingsService> init(String databaseDirectory) async {
    final service = SettingsService._();
    service.storage = await SettingsStorageSembast.init(databaseDirectory);
    await service.loadSettings();
    return service;
  }

  late PathTemplate _downloadPathTemplate;
  PathTemplate get downloadPathTemplate => _downloadPathTemplate;
  late String _authorsPathSeparator;
  String get authorsPathSeparator => _authorsPathSeparator;
  late String? _saveDirectory;
  String? get saveDirectory => _saveDirectory;

  List<PortalSession> get sessions => _sessions;

  PortalSession sessionByCode(String code) =>
      _sessions.firstWhere((s) => s.code == code);

  Future<void> loadSettings() async {
    _downloadPathTemplate = await storage.getDownloadPathTemplate();
    _authorsPathSeparator = await storage.getAuthorsPathSeparator();
    _saveDirectory = await storage.getSaveDirectory();

    final portalSettingsByCode = await storage.getPortalsSettings();
    _sessions = PortalFactory.portals.map((portal) {
      final settings = portal.service.settingsFromJson(
        portalSettingsByCode[portal.code],
      );
      return PortalSession(
        portal: portal,
        initialSettings: settings,
        persistCallback: _persistPortalSettings,
      );
    }).toList();
  }

  Future<void> _persistPortalSettings(
    String code,
    Map<String, dynamic> json,
  ) async {
    await storage.setPortalSettings(code, json);
  }

  void updateDownloadPathTemplate(PathTemplate template) {
    _downloadPathTemplate = template;
    storage.setDownloadPathTemplate(template);
  }

  void updateAuthorsPathSeparator(String separator) {
    _authorsPathSeparator = separator;
    storage.setAuthorsPathSeparator(separator);
  }

  void updateSaveDirectory(String? path) {
    _saveDirectory = path;
    storage.setSaveDirectory(path);
  }
}
