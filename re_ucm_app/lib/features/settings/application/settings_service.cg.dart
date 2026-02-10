import '../data/settings_storage.dart';
import '../domain/path_template.cg.dart';

class SettingsService {
  SettingsService._();

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

  Future<void> loadSettings() async {
    _downloadPathTemplate = await storage.getDownloadPathTemplate();
    _authorsPathSeparator = await storage.getAuthorsPathSeparator();
  }

  void updateDownloadPathTemplate(PathTemplate template) {
    _downloadPathTemplate = template;
    storage.setDownloadPathTemplate(template);
  }

  void updateAuthorsPathSeparator(String separator) {
    _authorsPathSeparator = separator;
    storage.setAuthorsPathSeparator(separator);
  }
}
