import 'package:path/path.dart' as path;
import 'package:sembast/sembast_io.dart';

import '../domain/recent_book.cg.dart';
import 'recent_books_storage.dart';

class RecentBooksStorageSembast implements RecentBooksStorage {
  late final Database db;
  final _store = StoreRef<String, Map<String, dynamic>>('RecentBooks');

  @override
  Future<void> setRecentBook(RecentBook book) async {
    await _store.record(book.portal.code + book.id).put(db, book.toJson());
  }

  @override
  Future<void> removeRecentBook(RecentBook book) async {
    await _store.record(book.portal.code + book.id).delete(db);
  }

  @override
  Future<List<RecentBook>> getRecentBooks() async {
    final records = await _store.find(db);

    return records.map((e) => RecentBook.fromJson(e.value)).toList();
  }

  RecentBooksStorageSembast._();

  static Future<RecentBooksStorageSembast> init(String databaseDirectory) async {
    var repo = RecentBooksStorageSembast._();

    repo.db = await databaseFactoryIo.openDatabase(
      path.join(databaseDirectory, 'recent_books_v2.db'),
    );
    return repo;
  }
}
