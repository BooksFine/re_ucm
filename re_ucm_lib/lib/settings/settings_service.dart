import 'package:re_ucm_core/logger.dart';

import '../portals/portal_session.cg.dart';
import '../portals/portal_factory.dart';
import 'data/settings_storage.dart';
import 'data/settings_storage_sembast.dart';
import 'domain/general_settings.cg.dart';
import 'domain/path_template.cg.dart';
import 'domain/recent_books_view_mode.dart';
import 'domain/save_format.dart';

class SettingsService {
  SettingsService._();

  late final SettingsStorage storage;
  late final List<PortalSession> _sessions;
  late GeneralSettings _settings;

  static Future<SettingsService> init(String databaseDirectory) async {
    final service = SettingsService._();
    service.storage = await SettingsStorageSembast.init(databaseDirectory);
    await service.loadSettings();
    return service;
  }

  List<PortalSession> get sessions => _sessions;

  PortalSession sessionByCode(String code) => _sessions.firstWhere(
    (s) => s.code == code,
    orElse: () => throw StateError('No session for portal code: $code'),
  );

  /// Null-safe вариант для presentation (detail/browser): вместо
  /// firstWhere с `!` — явный null с фолбэком выше по стеку.
  PortalSession? sessionByCodeOrNull(String code) {
    for (final s in _sessions) {
      if (s.code == code) return s;
    }
    return null;
  }

  GeneralSettings get generalSettings => _settings;

  void _saveSettings(GeneralSettings newSettings) {
    _settings = newSettings;
    storage.setGeneralSettings(newSettings).catchError((Object e, StackTrace st) {
      logger.e('Failed to persist general settings', error: e, stackTrace: st);
    });
  }

  void updateSettings(GeneralSettings Function(GeneralSettings current) updater) {
    _saveSettings(updater(_settings));
  }

  SaveFormat get saveFormat => _settings.saveFormat;
  void updateSaveFormat(SaveFormat format) {
    _saveSettings(_settings.copyWith(saveFormat: format));
  }

  String? get saveDirectory => _settings.saveDirectory;
  void updateSaveDirectory(String? path) {
    _saveSettings(_settings.copyWith(saveDirectory: path));
  }

  PathTemplate get downloadPathTemplate => _settings.downloadPathTemplate;
  void updateDownloadPathTemplate(PathTemplate template) {
    _saveSettings(_settings.copyWith(downloadPathTemplate: template));
  }

  String get authorsPathSeparator => _settings.authorsPathSeparator;
  void updateAuthorsPathSeparator(String separator) {
    _saveSettings(_settings.copyWith(authorsPathSeparator: separator));
  }

  bool get autoSaveOnComplete => _settings.autoSaveOnComplete;
  void updateAutoSaveOnComplete(bool value) {
    _saveSettings(_settings.copyWith(autoSaveOnComplete: value));
  }

  int get parallelImageDownloads => _settings.parallelImageDownloads;
  void updateParallelImageDownloads(int value) {
    _saveSettings(_settings.copyWith(parallelImageDownloads: value.clamp(1, 16)));
  }

  int get parallelChapterDownloads => _settings.parallelChapterDownloads;
  void updateParallelChapterDownloads(int value) {
    _saveSettings(
      _settings.copyWith(parallelChapterDownloads: value.clamp(1, 16)),
    );
  }

  List<String> get pinnedPortalCodes => _settings.pinnedPortalCodes;

  bool isPortalPinned(String code) => pinnedPortalCodes.contains(code);

  void togglePinPortal(String code) {
    updateSettings((current) {
      final list = List<String>.from(current.pinnedPortalCodes);
      if (list.contains(code)) {
        list.remove(code);
      } else {
        list.add(code);
      }
      return current.copyWith(pinnedPortalCodes: list);
    });
  }

  RecentBooksViewMode get recentBooksViewMode => _settings.recentBooksViewMode;
  void updateRecentBooksViewMode(RecentBooksViewMode mode) {
    _saveSettings(_settings.copyWith(recentBooksViewMode: mode));
  }

  bool get warnUnauthorizedDownloads => _settings.warnUnauthorizedDownloads;
  void updateWarnUnauthorizedDownloads(bool value) {
    _saveSettings(_settings.copyWith(warnUnauthorizedDownloads: value));
  }

  Future<void> loadSettings() async {
    _settings = await storage.getGeneralSettings();

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
