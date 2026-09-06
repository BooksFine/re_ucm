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
        effectiveFilePath != null && File(effectiveFilePath).existsSync();
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
