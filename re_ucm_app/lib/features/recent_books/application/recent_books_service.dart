import 'package:mobx/mobx.dart';
import 'package:re_ucm_core/models/book.dart';

import '../data/recent_books_storage.dart';
import '../domain/recent_book.cg.dart';

class RecentBooksService {
  late final RecentBooksStorage _repo;

  RecentBooksService._();
  static Future<RecentBooksService> init() async {
    var service = RecentBooksService._();
    service._repo = await RecentBooksStorageSembast.init();
    service._fetchRecentBooks();
    return service;
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

  Future _fetchRecentBooks() async {
    final recent = await _repo.getRecentBooks();
    recent.sort((a, b) => a.added.compareTo(b.added));
    recentBooks.clear();
    recentBooks.addAll(recent);
  }
}
