import 'dart:async';
import 'dart:typed_data';

import 'package:dart_book/dart_book.dart'
    show
        BookMetadata,
        Book,
        BookResource,
        BookContent,
        BookEncodingOptions,
        BookResourceNamingPolicy;
import 'package:mobx/mobx.dart';
import 'package:re_ucm_core/re_ucm_core.dart' hide logger;
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../core/constants.dart';
import '../../../core/logger.dart';
import 'book_saver.dart';
import 'book_share_text_builder.dart';
import 'book_sharer.dart';
import 'download_opener.dart';

part '../../../.gen/features/downloads/domain/download_task.cg.g.dart';

enum DownloadTaskStatus {
  idle,
  fetchingMetadata,
  downloading,
  completed,
  failed,
  cancelled,
}

/// Результат экспорта (сохранение на диск). Снэки и прочий UI —
/// в presentation, domain возвращает только факт.
sealed class ExportOutcome {
  const ExportOutcome();
}

class ExportSaved extends ExportOutcome {
  const ExportSaved(this.path);
  final String path;
}

class ExportCancelled extends ExportOutcome {
  const ExportCancelled();
}

class ExportFailed extends ExportOutcome {
  const ExportFailed(this.error);
  final Object error;
}

class DownloadTask = DownloadTaskBase with _$DownloadTask;

abstract class DownloadTaskBase with Store {
  final String bookId;
  final PortalSession session;
  final SettingsService settings;
  final RecentBooksService recentBooksService;
  final void Function(DownloadTask task)? onTaskCompleted;

  /// DI для тестов (saver/sharer/opener). Явно прокидываются из
  /// [DownloadsService.getOrCreateTask]; по умолчанию — реальные
  /// реализации. Encoder инлайнен ([BookExporter.encode] напрямую),
  /// т.к. бывший `BookEncoder` был passthrough без своей логики.
  final BookSaver _saver;
  final BookSharer _sharer;
  final DownloadOpener _opener;

  DownloadTaskBase({
    required this.bookId,
    required this.session,
    required this.settings,
    required this.recentBooksService,
    this.onTaskCompleted,
    BookMetadata? initialMetadata,
    BookSaver? saver,
    BookSharer? sharer,
    DownloadOpener? opener,
  }) : metadata = initialMetadata,
       saveFormat = settings.saveFormat,
       _saver = saver ?? BookSaver(),
       _sharer = sharer ?? BookSharer(),
       _opener = opener ?? const DefaultDownloadOpener();

  @observable
  BookMetadata? metadata;

  @observable
  DownloadTaskStatus status = DownloadTaskStatus.idle;

  @observable
  Progress progress = Progress(stage: Stages.none);

  @observable
  Book? resolvedBook;

  @observable
  List<ImageDownloadTask> failedTasks = [];

  @observable
  SaveFormat saveFormat;

  @observable
  bool addToRecent = true;

  @observable
  bool showResultOnComplete = true;

  @observable
  String? errorMessage;

  @observable
  bool isExporting = false;

  @observable
  String? savedFilePath;

  Future<void> open() async {
    final path = savedFilePath;
    if (path != null) {
      await _opener.openFile(path);
    }
  }

  bool _isCancelled = false;
  CancellationToken? _cancelToken;
  Uint8List? _encodedBytes;
  SaveFormat? _encodedFormat;
  List<BookResource> _resolvedResources = [];
  BookContent? _contentCache;
  Future<void>? _runningStart;

  /// Поколение фоновой конвертации для [updateSaveFormat].
  /// Устаревшие encode игнорируются, ошибка пишется в [errorMessage].
  int _convertGeneration = 0;

  /// Ключ задачи — та же формула, что и `DownloadsService.taskKey`.
  String get taskKey => '${session.portal.code}_$bookId';

  @computed
  bool get isActive =>
      status == DownloadTaskStatus.fetchingMetadata ||
      status == DownloadTaskStatus.downloading;

  @computed
  bool get isCompleted => status == DownloadTaskStatus.completed;

  @computed
  bool get isFailed => status == DownloadTaskStatus.failed;

  /// Единая формула заголовка для live/progress/list.
  String get displayTitle => metadata?.title ?? 'Книга #$bookId';

  /// Единая формула статуса: «Этап: cur / tot (pct)» либо message/этап.
  String get displayStatus {
    final p = progress;
    final tot = p.total ?? 0;
    if (tot > 0) {
      return '${p.stage.title}: ${p.counterText}';
    }
    return p.message ?? p.stage.title;
  }

  /// Единая формула прогресса 0..1.
  double? get progressValue => progress.normalized;

  /// Смена формата + персист в настройки + фоновая переконвертация,
  /// если книга уже скачана. Сайд-эффект осознанный (см. имя) —
  /// вызывается только из UI выбора формата.
  @action
  void updateSaveFormat(SaveFormat format) {
    if (saveFormat == format) return;
    saveFormat = format;
    settings.updateSaveFormat(format);
    if (isCompleted && resolvedBook != null) {
      _convertGeneration++;
      final generation = _convertGeneration;
      unawaited(_convertBook(generation));
    }
  }

  @action
  void updateAddToRecent(bool value) {
    addToRecent = value;
    if (value) {
      if (metadata != null) {
        recentBooksService.addRecentBook(metadata!, session.portal);
      }
    } else {
      final existing = recentBooksService.recentBooks
          .where((b) => b.portal.code == session.portal.code && b.id == bookId)
          .toList();
      for (final b in existing) {
        recentBooksService.removeRecentBook(b);
      }
    }
  }

  @action
  void updateShowResultOnComplete(bool value) {
    showResultOnComplete = value;
  }

  @action
  Future<void> start() async {
    if (isActive) return;
    if (_runningStart != null) return;

    _isCancelled = false;
    _cancelToken = CancellationToken();
    errorMessage = null;

    final completer = Completer<void>();
    _runningStart = completer.future;
    try {
      await fetchMetadata();
      if (_isCancelled) return;

      _trackRecent();

      runInAction(() => status = DownloadTaskStatus.downloading);
      logger.i('Downloading content for book [${session.code}-$bookId]');

      final throttled = _throttledProgress();
      await fetchContent(throttled);
      if (_isCancelled) return;

      await resolveBook(throttled);
      if (_isCancelled) return;

      await _convertBook();
      if (_isCancelled) return;

      finalizeSuccess();
    } catch (e, trace) {
      handleFailure(e, trace, 'Error downloading book [${session.code}-$bookId]');
    } finally {
      _runningStart = null;
      if (!completer.isCompleted) completer.complete();
    }
  }

  @action
  void cancel() {
    _isCancelled = true;
    _cancelToken?.cancel();
    _convertGeneration++;
    status = DownloadTaskStatus.cancelled;
    progress = Progress(stage: Stages.none);
  }

  @action
  void retry() {
    _contentCache = null;
    _resolvedResources = [];
    start();
  }

  @action
  void ignoreFailedTasks() {
    failedTasks = [];
  }

  @action
  Future<void> retryFailedImages() async {
    if (metadata == null || _contentCache == null) return;
    _isCancelled = false;
    _cancelToken = CancellationToken();
    errorMessage = null;
    runInAction(() => status = DownloadTaskStatus.downloading);
    runInAction(() => failedTasks = []);
    try {
      await resolveBook(_throttledProgress(minIntervalMs: 50));
      if (_isCancelled) return;
      await _convertBook();
      if (_isCancelled) return;
      finalizeSuccess();
    } catch (e, trace) {
      handleFailure(e, trace, 'Error retrying failed images');
    }
  }

  /// Этап 1: метаданные (no-op если уже есть).
  Future<void> fetchMetadata() async {
    if (metadata != null) return;
    runInAction(() => status = DownloadTaskStatus.fetchingMetadata);
    logger.i('Fetching metadata for book [${session.code}-$bookId]');
    final meta = await session.getBookMetadata(bookId);
    if (_isCancelled) return;
    runInAction(() {
      if (_isCancelled) return;
      metadata = meta;
    });
  }

  void _trackRecent() {
    if (addToRecent && metadata != null) {
      recentBooksService.addRecentBook(metadata!, session.portal);
    }
  }

  /// Этап 2: контент глав (кэш [_contentCache]).
  Future<void> fetchContent(void Function(Progress) onProgress) async {
    _contentCache ??= await session.getBookContent(
      bookId,
      onProgress: onProgress,
      cancelToken: _cancelToken,
    );
  }

  /// Этап 3: резолв ресурсов/книги. Переиспользуется в [retryFailedImages].
  Future<void> resolveBook(void Function(Progress) onProgress) async {
    final result = await BookExporter.resolveBook(
      metadata: metadata!,
      content: _contentCache!,
      resourceResolver: session.getResourceResolver(),
      initialResources: _resolvedResources,
      maxConcurrentDownloads: settings.parallelImageDownloads,
      onProgress: onProgress,
      cancelToken: _cancelToken,
    );
    if (_isCancelled) return;
    runInAction(() {
      resolvedBook = result.book;
      _resolvedResources = result.book.resources;
      failedTasks = result.failedTasks;
    });
  }

  /// Этап 4: успех.
  void finalizeSuccess() {
    runInAction(() {
      progress = Progress(stage: Stages.done);
      status = DownloadTaskStatus.completed;
    });
    logger.i('Download completed for book [${session.code}-$bookId]');
    onTaskCompleted?.call(this as DownloadTask);
  }

  void handleFailure(Object e, StackTrace trace, String logMessage) {
    if (_isCancelled) return;
    logger.e(logMessage, error: e, stackTrace: trace);
    runInAction(() {
      errorMessage = e.toString();
      progress = Progress(stage: Stages.error, message: e.toString());
      failedTasks = const [];
      status = DownloadTaskStatus.failed;
    });
  }

  /// Единый throttling прогресса для start/retry.
  /// Порог по умолчанию 33мс (~30fps для UI).
  void Function(Progress) _throttledProgress({int minIntervalMs = 33}) {
    var lastTimestamp = 0;
    var lastStage = Stages.none;
    var lastCurrent = -1;
    return (Progress p) {
      if (_isCancelled) return;
      final now = DateTime.now().millisecondsSinceEpoch;
      final isStageChanged = p.stage != lastStage;
      final isCountChanged = p.current != lastCurrent;
      final isDoneOrError =
          p.stage == Stages.done || p.stage == Stages.error;
      if (isDoneOrError ||
          isStageChanged ||
          isCountChanged ||
          (now - lastTimestamp > minIntervalMs)) {
        lastTimestamp = now;
        lastStage = p.stage;
        lastCurrent = p.current ?? -1;
        progress = p;
      }
    };
  }

  /// Шарит готовые fileName/text из [BookShareTextBuilder].
  Future<void> share() async {
    if (resolvedBook == null || metadata == null) return;
    runInAction(() => isExporting = true);
    try {
      final bytes = await _encodeCurrentBook();
      final meta = metadata!;
      final fileName = BookShareTextBuilder.buildFileName(
        meta,
        session.portal,
        downloadPathTemplate: settings.downloadPathTemplate,
        authorsPathSeparator: settings.authorsPathSeparator,
      );
      final text = BookShareTextBuilder.buildText(meta, resolvedBook);
      await _sharer.shareBook(
        bytes: bytes,
        fileName: fileName,
        text: text,
        format: saveFormat,
      );
    } finally {
      runInAction(() => isExporting = false);
    }
  }

  /// Сохранение без UI-зависимостей. Снэки — в presentation
  /// по возвращённому [ExportOutcome].
  Future<ExportOutcome> save() async {
    if (resolvedBook == null || metadata == null) {
      return const ExportCancelled();
    }
    runInAction(() => isExporting = true);
    try {
      final result = await _encodeAndSave();
      if (result == null) return const ExportCancelled();
      return ExportSaved(result);
    } catch (e, trace) {
      logger.e('Book export error', error: e, stackTrace: trace);
      return ExportFailed(e);
    } finally {
      runInAction(() => isExporting = false);
    }
  }

  Future<void> _convertBook([int? generation]) async {
    if (resolvedBook == null) return;
    runInAction(() => isExporting = true);

    bool isStale() => generation != null && generation != _convertGeneration;

    try {
      final savedPath = await _encodeAndSave(updateRecent: false);

      if (_isCancelled || isStale()) return;

      if (savedPath != null) {
        runInAction(() => savedFilePath = savedPath);
        unawaited(
          recentBooksService.updateRecentBookFile(
            portalCode: session.portal.code,
            bookId: bookId,
            savedFilePath: savedPath,
            saveFormat: saveFormat,
            downloadedAt: DateTime.now(),
          ),
        );
        logger.i('Saved book to $savedPath');
      } else if (!settings.autoSaveOnComplete && savedFilePath != null) {
        runInAction(() => savedFilePath = null);
      }
    } catch (e, trace) {
      if (isStale()) return;
      logger.e('Book conversion error', error: e, stackTrace: trace);
      runInAction(() => errorMessage = e.toString());
    } finally {
      if (!isStale()) {
        runInAction(() => isExporting = false);
      }
    }
  }

  /// Общий путь: encode → saveToFile → (опционально) updateRecentBookFile.
  /// Возвращает путь сохранённого файла или null (отмена/нет данных).
  Future<String?> _encodeAndSave({bool updateRecent = true}) async {
    final templateFileName = _templateFileName();
    final bytes = await _encodeCurrentBook(
      templateFileName: templateFileName,
    );

    final saveDirectory = settings.saveDirectory;
    if (saveDirectory == null || saveDirectory.isEmpty) {
      if (savedFilePath == null) return null;
    }

    if ((updateRecent || settings.autoSaveOnComplete || savedFilePath != null) &&
        saveDirectory != null &&
        saveDirectory.isNotEmpty) {
      final saved = await _saver.saveToFile(
        bytes: bytes,
        templateFileName: templateFileName,
        format: saveFormat,
        saveDirectory: saveDirectory,
      );
      if (saved == null) return null;
      runInAction(() => savedFilePath = saved.path);
      if (updateRecent) {
        unawaited(
          recentBooksService.updateRecentBookFile(
            portalCode: session.portal.code,
            bookId: bookId,
            savedFilePath: saved.path,
            saveFormat: saveFormat,
            downloadedAt: DateTime.now(),
          ),
        );
      }
      return saved.path;
    }
    return null;
  }

  String _templateFileName() {
    final data = metadata ?? resolvedBook!.metadata;
    return TemplateFormatter.buildTemplateFileName(
      data,
      session.portal,
      downloadPathTemplate: settings.downloadPathTemplate,
      authorsPathSeparator: settings.authorsPathSeparator,
    );
  }

  BookEncodingOptions _encodingOptions(String templateFileName) {
    final data = metadata ?? resolvedBook!.metadata;
    return BookEncodingOptions(
      documentId: 'UCM-${session.portal.code.toUpperCase()}-${data.id}',
      programUsed: 'ReUltimateCopyManager $appVersion',
      entryFilename: templateFileName,
      namingPolicy: BookResourceNamingPolicy.sequential,
    );
  }

  /// Единая точка кодирования с кэшем.
  Future<Uint8List> _encodeCurrentBook({String? templateFileName}) async {
    final format = saveFormat;
    if (templateFileName == null &&
        _encodedFormat == format &&
        _encodedBytes != null) {
      return _encodedBytes!;
    }
    final name = templateFileName ?? _templateFileName();
    final bytes = await BookExporter.encode(
      book: resolvedBook!,
      format: format,
      options: _encodingOptions(name),
      onProgress: (p) {
        progress = p;
      },
    );
    _encodedBytes = bytes;
    _encodedFormat = format;
    return bytes;
  }
}
