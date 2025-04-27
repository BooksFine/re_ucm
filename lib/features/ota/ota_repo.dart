import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

abstract interface class OTARepo {
  Future<String?> getLatestLaunchVersion();
  Future<void> setLatestLaunchVersion(String version);
}

class OTARepoBySembast implements OTARepo {
  final Database _database;
  final _store = StoreRef.main();

  OTARepoBySembast(this._database);

  @override
  Future<String?> getLatestLaunchVersion() async {
    return await _store.record('latestLaunchVersion').get(_database) as String?;
  }

  @override
  Future<void> setLatestLaunchVersion(String version) async {
    await _store.record('latestLaunchVersion').put(_database, version);
  }

  static Future<OTARepoBySembast> init() async {
    final appDocDir = await getApplicationSupportDirectory();
    final database = await databaseFactoryIo.openDatabase(
      '${appDocDir.path}/ota.db',
    );
    return OTARepoBySembast(database);
  }
}
