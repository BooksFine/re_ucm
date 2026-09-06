import 'dart:io';

import 'package:intl/intl.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../downloads/domain/download_task.cg.dart';
import '../../downloads/domain/downloads_service.cg.dart';

String formatDownloadedDate(DateTime date) {
  final now = DateTime.now();
  final isToday =
      now.year == date.year && now.month == date.month && now.day == date.day;
  final timeStr = DateFormat('HH:mm').format(date);
  if (isToday) {
    return 'сегодня в $timeStr';
  }
  final yesterday = now.subtract(const Duration(days: 1));
  final isYesterday =
      yesterday.year == date.year &&
      yesterday.month == date.month &&
      yesterday.day == date.day;
  if (isYesterday) {
    return 'вчера в $timeStr';
  }
  if (now.year == date.year) {
    return DateFormat('d MMM, HH:mm', 'ru').format(date);
  }
  return DateFormat('d MMM yyyy', 'ru').format(date);
}

SaveFormat getEffectiveFormat(RecentBook book, SettingsService settings) {
  return book.saveFormat ?? settings.saveFormat;
}

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

  /// Кэш существования файлов: resolve вызывается в build каждой карточки,
  /// дисковый I/O на каждый ребилд просаживает скролл. TTL 2с — баланс
  /// между актуальностью (удаление/скачивание) и перфом.
  static final Map<String, ({bool exists, int checkedAt})> _existsCache = {};

  static bool _cachedExists(String path) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final cached = _existsCache[path];
    if (cached != null && now - cached.checkedAt < 2000) {
      return cached.exists;
    }
    final exists = File(path).existsSync();
    _existsCache[path] = (exists: exists, checkedAt: now);
    // Защита от разрастания: чистим при >500 записей.
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

  /// Принудительно сбросить кэш для пути (после сохранения/удаления).
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
    final downloadedAt =
        (task != null && isCompleted && task.savedFilePath != null)
            ? book.downloadedAt ?? DateTime.now()
            : book.downloadedAt;
    return RecentBookItemState(
      task: task,
      isDownloading: isDownloading,
      isCompleted: isCompleted,
      effectiveFilePath: effectiveFilePath,
      fileExists: fileExists,
      downloadedAt: downloadedAt,
    );
  }
}
