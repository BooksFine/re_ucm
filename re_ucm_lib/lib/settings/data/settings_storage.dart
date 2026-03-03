import '../domain/path_template.cg.dart';

abstract interface class SettingsStorage {
  Future<void> setDownloadPathTemplate(PathTemplate template);
  Future<PathTemplate> getDownloadPathTemplate();
  Future<void> setAuthorsPathSeparator(String separator);
  Future<String> getAuthorsPathSeparator();
  Future<void> setSaveDirectory(String? path);
  Future<String?> getSaveDirectory();
  Future<void> setPortalSettings(String code, Map<String, Object?> settings);
  Future<Map<String, Map<String, Object?>>> getPortalsSettings();
}
