import '../domain/recent_book.cg.dart';

abstract interface class RecentBooksStorage {
  Future<void> setRecentBook(RecentBook book);
  Future<void> removeRecentBook(RecentBook book);
  Future<List<RecentBook>> getRecentBooks();
}
