import 'package:path/path.dart' as path;
import 'package:sembast/sembast_io.dart';

import '../domain/recent_book.cg.dart';
import 'recent_books_storage.dart';

class RecentBooksStorageSembast implements RecentBooksStorage {
  late final Database db;
  final _store = StoreRef<String, Map<String, dynamic>>('RecentBooks');
  bool _migrated = false;

  @override
  Future<void> setRecentBook(RecentBook book) async {
    await _store
        .record(RecentBook.keyFor(book.portal.code, book.id))
        .put(db, book.toJson());
  }

  @override
  Future<void> removeRecentBook(RecentBook book) async {
    await _store
        .record(RecentBook.keyFor(book.portal.code, book.id))
        .delete(db);
  }

  @override
  Future<List<RecentBook>> getRecentBooks() async {
    final records = await _store.find(db);
    if (!_migrated) {
      await _migrateLegacyKeys(records);
      _migrated = true;
    }

    return records.map((e) => RecentBook.fromJson(e.value)).toList();
  }

  /// Миграция ключей, записанных до канонического формата
  /// [RecentBook.keyFor] (`portal.code + id` без разделителя):
  /// перезаписывает такие записи под каноническим ключом и удаляет
  /// старые, чтобы не оставалось дублей-сирот.
  Future<void> _migrateLegacyKeys(
    List<RecordSnapshot<String, Map<String, dynamic>>> records,
  ) async {
    for (final record in records) {
      final book = RecentBook.fromJson(record.value);
      final canonicalKey = RecentBook.keyFor(book.portal.code, book.id);
      if (record.key != canonicalKey) {
        await _store.record(canonicalKey).put(db, record.value);
        await _store.record(record.key).delete(db);
      }
    }
  }

  RecentBooksStorageSembast._();

  static Future<RecentBooksStorageSembast> init(
    String databaseDirectory,
  ) async {
    var repo = RecentBooksStorageSembast._();

    repo.db = await databaseFactoryIo.openDatabase(
      path.join(databaseDirectory, 'recent_books_v2.db'),
    );
    return repo;
  }
}
