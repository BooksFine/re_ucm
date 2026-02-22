import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

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

class SettingsStorageSembast implements SettingsStorage {
  late final Database db;
  final _store = StoreRef<String, dynamic>('Settings');
  final _portalsStore = StoreRef<String, Map<String, Object?>>(
    'PortalSettings',
  );

  SettingsStorageSembast._();

  static Future<SettingsStorageSembast> init() async {
    var repo = SettingsStorageSembast._();
    var dir = await getApplicationSupportDirectory();

    repo.db = await databaseFactoryIo.openDatabase(
      path.join(dir.path, 'settings.db'),
      version: 1,
    );
    return repo;
  }

  @override
  Future<void> setDownloadPathTemplate(PathTemplate template) async {
    await _store.record('downloadPathTemplate').put(db, template.toMap());
  }

  @override
  Future<PathTemplate> getDownloadPathTemplate() async {
    final Map<String, dynamic>? templateJson = await _store
        .record('downloadPathTemplate')
        .get(db);
    return templateJson != null
        ? PathTemplateMapper.fromMap(templateJson)
        : PathTemplate.initial();
  }

  @override
  Future<void> setAuthorsPathSeparator(String separator) async {
    await _store.record('authorsPathSeparator').put(db, separator);
  }

  @override
  Future<String> getAuthorsPathSeparator() async {
    return await _store.record('authorsPathSeparator').get(db) ?? '';
  }

  @override
  Future<void> setSaveDirectory(String? path) async {
    final record = _store.record('saveDirectory');
    if (path == null) {
      await record.delete(db);
    } else {
      await record.put(db, path);
    }
  }

  @override
  Future<String?> getSaveDirectory() async {
    return await _store.record('saveDirectory').get(db);
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
