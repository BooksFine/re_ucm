import 'package:dart_book/dart_book.dart';
import 'package:mobx/mobx.dart';
import 'package:re_ucm_core/models/portal.dart';

import '../settings/domain/save_format.dart';
import 'data/recent_books_storage.dart';
import 'data/recent_books_storage_sembast.dart';
import 'domain/recent_book.cg.dart';

part '../.gen/recent_books/recent_books_service.cg.g.dart';

class RecentBooksService extends _RecentBooksService with _$RecentBooksService {
  RecentBooksService._();

  static Future<RecentBooksService> init(String databaseDirectory) async {
    var service = RecentBooksService._()
      .._initRepo(await RecentBooksStorageSembast.init(databaseDirectory))
      .._fetchRecentBooks();
    return service;
  }
}

abstract class _RecentBooksService with Store {
  late final RecentBooksStorage _repo;

  void _initRepo(RecentBooksStorage repo) => _repo = repo;

  final recentBooks = <RecentBook>[].asObservable();

  Future<void> addRecentBook(BookMetadata metadata, Portal portal) async {
    final existing = recentBooks.cast<RecentBook?>().firstWhere(
      (e) => e != null && e.portal.code + e.id == portal.code + metadata.id,
      orElse: () => null,
    );

    recentBooks.removeWhere(
      (e) => e.portal.code + e.id == portal.code + metadata.id,
    );

    final authors = metadata.contributors
        .map((e) => e.name.toDisplayString())
        .join(', ');

    final recentBook = RecentBook(
      id: metadata.id,
      title: metadata.title,
      authors: authors,
      coverUrl: metadata.cover?.ref.id,
      seriesName: metadata.primarySeries?.name,
      seriesNumber: metadata.primarySeries?.number,
      portal: portal,
      added: DateTime.now(),
      savedFilePath: existing?.savedFilePath,
      downloadedAt: existing?.downloadedAt,
      saveFormat: existing?.saveFormat,
    );
    recentBooks.add(recentBook);

    _repo.setRecentBook(recentBook);
  }

  Future<void> updateRecentBookFile({
    required String portalCode,
    required String bookId,
    required String savedFilePath,
    required SaveFormat saveFormat,
    DateTime? downloadedAt,
  }) async {
    final index = recentBooks.indexWhere(
      (e) => e.portal.code == portalCode && e.id == bookId,
    );
    if (index != -1) {
      final existing = recentBooks[index];
      final updated = existing.copyWith(
        savedFilePath: savedFilePath,
        saveFormat: saveFormat,
        downloadedAt: downloadedAt ?? DateTime.now(),
      );
      recentBooks[index] = updated;
      await _repo.setRecentBook(updated);
    }
  }

  Future<void> removeRecentBook(RecentBook book) async {
    recentBooks.removeWhere(
      (e) => e.portal.code + e.id == book.portal.code + book.id,
    );
    _repo.removeRecentBook(book);
  }

  Future<void> restoreRecentBook(RecentBook book) async {
    recentBooks.add(book);
    recentBooks.sort(
      (RecentBook a, RecentBook b) => a.added.compareTo(b.added),
    );
    _repo.setRecentBook(book);
  }

  Future _fetchRecentBooks() async {
    final recent = await _repo.getRecentBooks();
    recent.sort((RecentBook a, RecentBook b) => a.added.compareTo(b.added));
    recentBooks.clear();
    recentBooks.addAll(recent);
  }
}
