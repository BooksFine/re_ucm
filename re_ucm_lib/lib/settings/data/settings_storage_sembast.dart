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

  Future<T?> _readLegacy<T>(String key, T Function(dynamic) convert) async {
    try {
      final val = await _store.record(key).get(db);
      if (val != null) return convert(val);
    } catch (_) {}
    return null;
  }

  Future<GeneralSettings> _readLegacySettings() async {
    var settings = GeneralSettings.initial();

    final template = await _readLegacy(
      'downloadPathTemplate',
      (v) => v is Map ? PathTemplate.fromJson(Map<String, dynamic>.from(v)) : null,
    );
    if (template != null) settings = settings.copyWith(downloadPathTemplate: template);

    final sep = await _readLegacy('authorsPathSeparator', (v) => v is String ? v : null);
    if (sep != null) settings = settings.copyWith(authorsPathSeparator: sep);

    final dir = await _readLegacy('saveDirectory', (v) => v is String ? v : null);
    if (dir != null) settings = settings.copyWith(saveDirectory: dir);

    final fmt = await _readLegacy('saveFormat', (v) => v is String ? SaveFormat.fromJson(v) : null);
    if (fmt != null) settings = settings.copyWith(saveFormat: fmt);

    final autoSave = await _readLegacy('autoSaveOnComplete', (v) => v is bool ? v : null);
    if (autoSave != null) settings = settings.copyWith(autoSaveOnComplete: autoSave);

    final imgParallel = await _readLegacy('parallelImageDownloads', (v) => v is int ? v : null);
    if (imgParallel != null) settings = settings.copyWith(parallelImageDownloads: imgParallel);

    final chParallel = await _readLegacy('parallelChapterDownloads', (v) => v is int ? v : null);
    if (chParallel != null) settings = settings.copyWith(parallelChapterDownloads: chParallel);

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
