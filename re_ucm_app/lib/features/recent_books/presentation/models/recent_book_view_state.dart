import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../downloads/domain/download_task.cg.dart';
import '../../../downloads/domain/downloads_service.cg.dart';

/// Чистый UI ViewModel элемента недавней книги.
///
/// Не выполняет синхронного I/O в UI-потоке, опираясь на статус
/// завершённости [DownloadTask] и сохранённый путь.
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

  /// Устаревший метод для обратной совместимости (кэш упразднён).
  @Deprecated('File cache is no longer used')
  static void invalidateFileCache(String? path) {}

  factory RecentBookItemState.resolve(
    RecentBook book,
    DownloadsService downloadsService,
  ) {
    final key = DownloadsServiceBase.taskKey(book.portal.code, book.id);
    final task = downloadsService.tasks[key];
    final isDownloading = task?.isActive ?? false;
    final isCompleted = task?.isCompleted ?? false;
    final effectiveFilePath = task?.savedFilePath ?? book.savedFilePath;

    // Книга готова к чтению, если задача завершена успешно, либо у книги
    // уже есть сохранённый локальный путь из истории (и сейчас не перезагружается).
    final fileExists = (isCompleted || book.savedFilePath != null) &&
        effectiveFilePath != null &&
        !isDownloading;

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

/// Алиас типа [RecentBookItemState] для слоя презентации.
typedef RecentBookViewState = RecentBookItemState;
