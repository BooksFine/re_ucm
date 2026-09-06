import 'package:path/path.dart' as path;
import 'package:re_ucm_core/logger.dart';
import 'package:sembast/sembast_io.dart';

import '../domain/general_settings.cg.dart';
import '../domain/path_template.cg.dart';
import '../domain/save_format.dart';
import 'settings_storage.dart';

class SettingsStorageSembast implements SettingsStorage {
  late final Database db;
  final _store = StoreRef<String, dynamic>('Settings');
  final _portalsStore = StoreRef<String, Map<String, Object?>>(
    'PortalSettings',
  );

  static const _generalSettingsKey = 'generalSettings';

  SettingsStorageSembast._();

  static Future<SettingsStorageSembast> init(String databaseDirectory) async {
    final repo = SettingsStorageSembast._();

    repo.db = await databaseFactoryIo.openDatabase(
      path.join(databaseDirectory, 'settings.db'),
      version: 3,
      onVersionChanged: (db, oldVer, newVer) async {
        await db.dropAll();
      },
    );
    return repo;
  }

  @override
  Future<void> setGeneralSettings(GeneralSettings settings) async {
    await _store.record(_generalSettingsKey).put(db, settings.toJson());
  }

  @override
  Future<GeneralSettings> getGeneralSettings() async {
    try {
      final record = await _store.record(_generalSettingsKey).get(db);
      if (record is Map) {
        return GeneralSettings.fromJson(Map<String, dynamic>.from(record));
      }
    } catch (e, trace) {
      logger.w(
        'Failed to deserialize generalSettings, falling back to legacy or default',
        error: e,
        stackTrace: trace,
      );
    }

    final legacySettings = await _readLegacySettings();
    await setGeneralSettings(legacySettings);
    return legacySettings;
  }

  Future<GeneralSettings> _readLegacySettings() async {
    var settings = GeneralSettings.initial();

    try {
      final record = await _store.record('downloadPathTemplate').get(db);
      if (record is Map) {
        settings = settings.copyWith(
          downloadPathTemplate: PathTemplate.fromJson(
            Map<String, dynamic>.from(record),
          ),
        );
      }
    } catch (_) {}

    try {
      final val = await _store.record('authorsPathSeparator').get(db);
      if (val is String) settings = settings.copyWith(authorsPathSeparator: val);
    } catch (_) {}

    try {
      final val = await _store.record('saveDirectory').get(db);
      if (val is String) settings = settings.copyWith(saveDirectory: val);
    } catch (_) {}

    try {
      final formatStr = await _store.record('saveFormat').get(db) as String?;
      if (formatStr != null) {
        settings = settings.copyWith(saveFormat: SaveFormat.fromJson(formatStr));
      }
    } catch (_) {}

    try {
      final val = await _store.record('autoSaveOnComplete').get(db);
      if (val is bool) settings = settings.copyWith(autoSaveOnComplete: val);
    } catch (_) {}

    try {
      final val = await _store.record('parallelImageDownloads').get(db);
      if (val is int) settings = settings.copyWith(parallelImageDownloads: val);
    } catch (_) {}

    try {
      final val = await _store.record('parallelChapterDownloads').get(db);
      if (val is int) {
        settings = settings.copyWith(parallelChapterDownloads: val);
      }
    } catch (_) {}

    return settings;
  }

  @override
  Future<void> setPortalSettings(String code, Map<String, Object?> settings) =>
      _portalsStore.record(code).put(db, settings);

  @override
  Future<Map<String, Map<String, Object?>>> getPortalsSettings() async {
    final records = await _portalsStore.find(db);
    final map = <String, Map<String, Object?>>{};
    for (final record in records) {
      map[record.key] = record.value;
    }
    return map;
  }
}
