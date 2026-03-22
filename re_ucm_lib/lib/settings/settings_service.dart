import '../portals/portal_session.cg.dart';
import '../portals/portal_factory.dart';
import 'data/settings_storage.dart';
import 'data/settings_storage_sembast.dart';
import 'domain/path_template.cg.dart';
import 'domain/save_format.dart';

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

  List<PortalSession> get sessions => _sessions;

  PortalSession sessionByCode(String code) =>
      _sessions.firstWhere((s) => s.code == code);

  late SaveFormat _saveFormat;
  SaveFormat get saveFormat => _saveFormat;
  void updateSaveFormat(SaveFormat format) => storage.setSaveFormat(format);

  late String? _saveDirectory;
  String? get saveDirectory => _saveDirectory;
  void updateSaveDirectory(String? path) {
    _saveDirectory = path;
    storage.setSaveDirectory(path);
  }

  late PathTemplate _downloadPathTemplate;
  PathTemplate get downloadPathTemplate => _downloadPathTemplate;
  void updateDownloadPathTemplate(PathTemplate template) {
    _downloadPathTemplate = template;
    storage.setDownloadPathTemplate(template);
  }

  late String _authorsPathSeparator;
  String get authorsPathSeparator => _authorsPathSeparator;
  void updateAuthorsPathSeparator(String separator) {
    _authorsPathSeparator = separator;
    storage.setAuthorsPathSeparator(separator);
  }

  Future<void> loadSettings() async {
    _downloadPathTemplate = await storage.getDownloadPathTemplate();
    _authorsPathSeparator = await storage.getAuthorsPathSeparator();
    _saveDirectory = await storage.getSaveDirectory();
    _saveFormat = await storage.getSaveFormat() ?? SaveFormat.fb2Zip;

    final portalSettingsByCode = await storage.getPortalsSettings();
    _sessions = PortalFactory.portals.map((portal) {
      final settings = portal.service.settingsFromJson(
        portalSettingsByCode[portal.code],
      );
      return PortalSession(
        portal: portal,
        initialSettings: settings,
        persistCallback: storage.setPortalSettings,
      );
    }).toList();
  }
}
