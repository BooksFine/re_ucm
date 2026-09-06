import 'package:dart_book/dart_book.dart';
import 'package:mobx/mobx.dart';
import 'package:re_ucm_core/re_ucm_core.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import 'book_saver.dart';
import 'book_sharer.dart';
import 'download_opener.dart';
import 'download_task.cg.dart';

part '../../../.gen/features/downloads/domain/downloads_service.cg.g.dart';

class DownloadsService = DownloadsServiceBase with _$DownloadsService;

abstract class DownloadsServiceBase with Store {
  final SettingsService settings;
  final RecentBooksService recentBooksService;

  DownloadsServiceBase({
    required this.settings,
    required this.recentBooksService,
  });

  void Function(DownloadTask task)? onTaskCompletedGlobal;

  @observable
  ObservableMap<String, DownloadTask> tasks =
      ObservableMap<String, DownloadTask>();

  static String taskKey(String portalCode, String bookId) =>
      '${portalCode}_$bookId';

  @computed
  List<DownloadTask> get activeTasks =>
      tasks.values.where((t) => t.isActive).toList();

  @computed
  int get activeCount => activeTasks.length;

  @computed
  bool get hasActiveTasks => activeCount > 0;

  @computed
  List<DownloadTask> get completedTasks =>
      tasks.values.where((t) => t.isCompleted).toList();

  @computed
  List<DownloadTask> get allTasks => tasks.values.toList();

  @computed
  int get totalCount => tasks.length;

  @computed
  double? get totalProgress {
    final active = activeTasks;
    if (active.isEmpty) return null;
    double sum = 0;
    int counted = 0;
    for (final t in active) {
      final normalized = t.progress.normalized;
      if (normalized != null) {
        sum += normalized;
        counted++;
      }
    }
    if (counted == 0) return null;
    return sum / counted;
  }

  @action
  DownloadTask getOrCreateTask({
    required PortalSession session,
    required String bookId,
    BookMetadata? initialMetadata,
    BookSaver? saver,
    BookSharer? sharer,
    DownloadOpener? opener,
  }) {
    final key = taskKey(session.portal.code, bookId);
    if (tasks.containsKey(key)) {
      final existing = tasks[key]!;
      if (initialMetadata != null && existing.metadata == null) {
        existing.metadata = initialMetadata;
      }
      return existing;
    }

    final newTask = DownloadTask(
      bookId: bookId,
      session: session,
      settings: settings,
      recentBooksService: recentBooksService,
      initialMetadata: initialMetadata,
      saver: saver,
      sharer: sharer,
      opener: opener,
      onTaskCompleted: (task) {
        onTaskCompletedGlobal?.call(task);
      },
    );

    tasks[key] = newTask;
    return newTask;
  }

  @action
  DownloadTask startDownload({
    required PortalSession session,
    required String bookId,
    BookMetadata? initialMetadata,
    BookSaver? saver,
    BookSharer? sharer,
    DownloadOpener? opener,
  }) {
    final task = getOrCreateTask(
      session: session,
      bookId: bookId,
      initialMetadata: initialMetadata,
      saver: saver,
      sharer: sharer,
      opener: opener,
    );

    if (task.status == DownloadTaskStatus.idle ||
        task.status == DownloadTaskStatus.cancelled ||
        task.status == DownloadTaskStatus.failed) {
      task.start();
    }

    return task;
  }

  @action
  void removeTask(String portalCode, String bookId) {
    final key = taskKey(portalCode, bookId);
    final task = tasks[key];
    if (task != null) {
      task.cancel();
      tasks.remove(key);
    }
  }

  @action
  void clearCompletedTasks() {
    tasks.removeWhere((key, task) => task.isCompleted);
  }
}
