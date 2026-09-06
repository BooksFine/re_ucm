import '../domain/general_settings.cg.dart';

abstract interface class SettingsStorage {
  Future<GeneralSettings> getGeneralSettings();
  Future<void> setGeneralSettings(GeneralSettings settings);
  Future<void> setPortalSettings(String code, Map<String, Object?> settings);
  Future<Map<String, Map<String, Object?>>> getPortalsSettings();
}
