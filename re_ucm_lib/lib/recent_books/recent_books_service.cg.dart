import 'package:mobx/mobx.dart';
import 'package:re_ucm_core/models/book.dart';

import 'data/recent_books_storage.dart';
import 'data/recent_books_storage_sembast.dart';
import 'domain/recent_book.cg.dart';

part '../.gen/recent_books/recent_books_service.cg.g.dart';

class RecentBooksService = RecentBooksServiceBase with _$RecentBooksService;

abstract class RecentBooksServiceBase with Store {
  late final RecentBooksStorage _repo;

  RecentBooksServiceBase._();
  
  static Future<RecentBooksService> init(String databaseDirectory) async {
    var service = RecentBooksService._().._initRepo(await RecentBooksStorageSembast.init(databaseDirectory));
    service._fetchRecentBooks();
    return service;
  }

  void _initRepo(RecentBooksStorage repo) {
    _repo = repo;
  }

  final recentBooks = <RecentBook>[].asObservable();

  Future<void> addRecentBook(Book book) async {
    recentBooks.removeWhere(
      (e) => e.portal.code + e.id == book.portal.code + book.id,
    );

    final recentBook = RecentBook(
      id: book.id,
      title: book.title,
      authors: book.authors.map((e) => e.name).join(', '),
      coverUrl: book.coverUrl,
      seriesName: book.series?.name,
      seriesNumber: book.series?.number,
      portal: book.portal,
      added: DateTime.now(),
    );
    recentBooks.add(recentBook);

    _repo.setRecentBook(recentBook);
  }

  Future<void> removeRecentBook(RecentBook book) async {
    recentBooks.removeWhere(
      (e) => e.portal.code + e.id == book.portal.code + book.id,
    );
    _repo.removeRecentBook(book);
  }

  Future<void> restoreRecentBook(RecentBook book) async {
    recentBooks.add(book);
    recentBooks.sort((RecentBook a, RecentBook b) => a.added.compareTo(b.added));
    _repo.setRecentBook(book);
  }

  Future _fetchRecentBooks() async {
    final recent = await _repo.getRecentBooks();
    recent.sort((RecentBook a, RecentBook b) => a.added.compareTo(b.added));
    recentBooks.clear();
    recentBooks.addAll(recent);
  }
}
