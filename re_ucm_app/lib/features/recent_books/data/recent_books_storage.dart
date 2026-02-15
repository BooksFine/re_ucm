import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

import '../domain/recent_book.cg.dart';

abstract interface class RecentBooksStorage {
  Future<void> setRecentBook(RecentBook book);
  Future<void> removeRecentBook(RecentBook book);
  Future<List<RecentBook>> getRecentBooks();
}

class RecentBooksStorageSembast implements RecentBooksStorage {
  late final Database db;
  final _store = StoreRef<String, Map<String, dynamic>>('RecentBooks');

  @override
  Future<void> setRecentBook(RecentBook book) async {
    await _store.record(book.portal.code + book.id).put(db, book.toMap());
  }

  @override
  Future<void> removeRecentBook(RecentBook book) async {
    await _store.record(book.portal.code + book.id).delete(db);
  }

  @override
  Future<List<RecentBook>> getRecentBooks() async {
    final records = await _store.find(db);
    return records.map((e) => RecentBookMapper.fromMap(e.value)).toList();
  }

  RecentBooksStorageSembast._();

  static Future<RecentBooksStorageSembast> init() async {
    var repo = RecentBooksStorageSembast._();
    var dir = await getApplicationSupportDirectory();

    repo.db = await databaseFactoryIo.openDatabase(
      path.join(dir.path, 'recent_books_v2.db'),
    );
    return repo;
  }
}
