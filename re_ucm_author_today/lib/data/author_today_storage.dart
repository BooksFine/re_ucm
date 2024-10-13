import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

abstract interface class AuthorTodayStorage {
  Future<String?> getUserId();
  Future<void> setUserId(String userId);
  Future<String?> getToken();
  Future<void> setToken(String token);
  Future<void> clear();
}

class ATStorageSembast implements AuthorTodayStorage {
  late final Database db;
  final _store = StoreRef('AuthorToday');

  @override
  Future<String?> getUserId() async {
    return await _store.record('userId').get(db) as String?;
  }

  @override
  Future<void> setUserId(String userId) async {
    await _store.record('userId').put(db, userId);
  }

  @override
  Future<String?> getToken() async {
    return await _store.record('token').get(db) as String?;
  }

  @override
  Future<void> setToken(String token) async {
    await _store.record('token').put(db, token);
  }

  @override
  Future<void> clear() async {
    await _store.delete(db);
  }

  static init() async {
    var repo = ATStorageSembast();
    var dir = await getApplicationSupportDirectory();

    repo.db = await databaseFactoryIo.openDatabase(
      '${dir.path}/author_today.db',
    );
    return repo;
  }
}
