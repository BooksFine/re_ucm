import 'dart:io';

import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../downloads/domain/download_task.cg.dart';
import '../../downloads/domain/downloads_service.cg.dart';

class RecentBookItemState {
  final DownloadTask? task;
  final bool isDownloading;
  final bool isCompleted;
  final String? effectiveFilePath;
  final bool fileExists;
  final DateTime? downloadedAt;

  const RecentBookItemState({
    required this.task,
    required this.isDownloading,
    required this.isCompleted,
    required this.effectiveFilePath,
    required this.fileExists,
    required this.downloadedAt,
  });

  static final Map<String, ({bool exists, int checkedAt})> _existsCache = {};

  static bool _cachedExists(String path) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final cached = _existsCache[path];
    if (cached != null && now - cached.checkedAt < 2000) {
      return cached.exists;
    }
    final exists = File(path).existsSync();
    _existsCache[path] = (exists: exists, checkedAt: now);
    if (_existsCache.length > 500) {
      _existsCache.remove(
        _existsCache.keys.firstWhere(
          (k) => k != path,
          orElse: () => path,
        ),
      );
    }
    return exists;
  }

  static void invalidateFileCache(String? path) {
    if (path != null) _existsCache.remove(path);
  }

  factory RecentBookItemState.resolve(
    RecentBook book,
    DownloadsService downloadsService,
  ) {
    final key = DownloadsServiceBase.taskKey(book.portal.code, book.id);
    final task = downloadsService.tasks[key];
    final isDownloading = task?.isActive ?? false;
    final isCompleted = task?.isCompleted ?? false;
    final effectiveFilePath = task?.savedFilePath ?? book.savedFilePath;
    final fileExists =
        effectiveFilePath != null && _cachedExists(effectiveFilePath);
    return RecentBookItemState(
      task: task,
      isDownloading: isDownloading,
      isCompleted: isCompleted,
      effectiveFilePath: effectiveFilePath,
      fileExists: fileExists,
      downloadedAt: book.downloadedAt,
    );
  }
}
