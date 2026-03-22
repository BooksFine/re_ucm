import 'package:path/path.dart' as path;
import 'package:re_ucm_lib/settings/domain/save_format.dart';
import 'package:sembast/sembast_io.dart';

import '../domain/path_template.cg.dart';
import 'settings_storage.dart';

class SettingsStorageSembast implements SettingsStorage {
  late final Database db;
  final _store = StoreRef<String, dynamic>('Settings');
  final _portalsStore = StoreRef<String, Map<String, Object?>>(
    'PortalSettings',
  );

  SettingsStorageSembast._();

  static Future<SettingsStorageSembast> init(String databaseDirectory) async {
    var repo = SettingsStorageSembast._();

    repo.db = await databaseFactoryIo.openDatabase(
      path.join(databaseDirectory, 'settings.db'),
      version: 2,
      onVersionChanged: (db, oldVer, newVer) {
        switch (oldVer) {
          case 1:
            db.dropAll();
        }
      },
    );
    return repo;
  }

  @override
  Future<void> setDownloadPathTemplate(PathTemplate template) async {
    await _store.record('downloadPathTemplate').put(db, template.toJson());
  }

  @override
  Future<PathTemplate> getDownloadPathTemplate() async {
    final Map<String, dynamic>? templateJson =
        await _store.record('downloadPathTemplate').get(db)
            as Map<String, dynamic>?;
    return templateJson != null
        ? PathTemplate.fromJson(templateJson)
        : PathTemplate.initial();
  }

  @override
  Future<void> setAuthorsPathSeparator(String separator) async {
    await _store.record('authorsPathSeparator').put(db, separator);
  }

  @override
  Future<String> getAuthorsPathSeparator() async {
    return await _store.record('authorsPathSeparator').get(db) as String? ??
        ', ';
  }

  @override
  Future<void> setSaveDirectory(String? dirPath) async {
    final record = _store.record('saveDirectory');
    if (dirPath == null) {
      await record.delete(db);
    } else {
      await record.put(db, dirPath);
    }
  }

  @override
  Future<String?> getSaveDirectory() async {
    return await _store.record('saveDirectory').get(db) as String?;
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

  @override
  Future<void> setSaveFormat(SaveFormat format) async =>
      await _store.record('saveFormat').put(db, format.toJson());

  @override
  Future<SaveFormat?> getSaveFormat() async {
    final formatStr = await _store.record('saveFormat').get(db) as String?;
    if (formatStr == null) return null;
    try {
      return SaveFormat.fromJson(formatStr);
    } catch (e) {
      await _store.record('saveFormat').delete(db);
      return null;
    }
  }
}
