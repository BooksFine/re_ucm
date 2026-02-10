import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

import '../domain/path_template.cg.dart';

abstract interface class SettingsStorage {
  Future<void> setDownloadPathTemplate(PathTemplate template);
  Future<PathTemplate> getDownloadPathTemplate();
  Future<void> setAuthorsPathSeparator(String separator);
  Future<String> getAuthorsPathSeparator();
}

class SettingsStorageSembast implements SettingsStorage {
  late final Database db;
  final _store = StoreRef<String, dynamic>('Settings');
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
    await _store.record('downloadPathTemplate').put(db, template.toJson());
  }

  @override
  Future<PathTemplate> getDownloadPathTemplate() async {
    final Map<String, dynamic>? templateJson = await _store
        .record('downloadPathTemplate')
        .get(db);
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
    return await _store.record('authorsPathSeparator').get(db) ?? '';
  }
}
