import 'dart:async';
import 'dart:typed_data';

import 'package:dart_book/dart_book.dart' show BookMetadata, Book, BookResource, BookContent, BookEncodingOptions, BookResourceNamingPolicy;
import 'package:mobx/mobx.dart';
import 'package:open_file/open_file.dart';
import 'package:re_ucm_core/re_ucm_core.dart' hide logger;
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../core/constants.dart';
import '../../../core/logger.dart';
import 'book_encoder.dart';
import 'book_saver.dart';
import 'book_sharer.dart';

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
  final BookEncoder _encoder;
  final BookSaver _saver;
  final BookSharer _sharer;

  DownloadTaskBase({
    required this.bookId,
    required this.session,
    required this.settings,
    required this.recentBooksService,
    this.onTaskCompleted,
    BookMetadata? initialMetadata,
    BookEncoder? encoder,
    BookSaver? saver,
    BookSharer? sharer,
  })  : metadata = initialMetadata,
        saveFormat = settings.saveFormat,
        _encoder = encoder ?? BookEncoder(),
        _saver = saver ?? BookSaver(),
        _sharer = sharer ?? BookSharer();

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
    if (savedFilePath != null) {
      await OpenFile.open(savedFilePath);
    }
  }

  bool _isCancelled = false;
  CancellationToken? _cancelToken;
  Uint8List? _encodedBytes;
  SaveFormat? _encodedFormat;
  List<BookResource> _resolvedResources = [];
  BookContent? _contentCache;

  @computed
  bool get isActive =>
      status == DownloadTaskStatus.fetchingMetadata ||
      status == DownloadTaskStatus.downloading;

  @computed
  bool get isCompleted => status == DownloadTaskStatus.completed;

  @computed
  bool get isFailed => status == DownloadTaskStatus.failed;

  /// Смена формата + персист в настройки + фоновая переконвертация,
  /// если книга уже скачана. Сайд-эффект осознанный (см. имя) —
  /// вызывается только из UI выбора формата.
  @action
  void updateSaveFormat(SaveFormat format) {
    if (saveFormat == format) return;
    saveFormat = format;
    settings.updateSaveFormat(format);
    if (isCompleted && resolvedBook != null) {
      unawaited(_convertBook());
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

    _isCancelled = false;
    _cancelToken = CancellationToken();
    errorMessage = null;

    try {
      if (metadata == null) {
        status = DownloadTaskStatus.fetchingMetadata;
        logger.i('Fetching metadata for book [${session.code}-$bookId]');
        final meta = await session.getBookMetadata(bookId);
        if (_isCancelled) return;
        metadata = meta;
      }

      if (addToRecent && metadata != null) {
        recentBooksService.addRecentBook(metadata!, session.portal);
      }

      status = DownloadTaskStatus.downloading;
      logger.i('Downloading content for book [${session.code}-$bookId]');

      final throttled = _throttledProgress();
      final content = _contentCache ??= await session.getBookContent(
        bookId,
        onProgress: throttled,
        cancelToken: _cancelToken,
      );
      if (_isCancelled) return;

      final result = await BookExporter.resolveBook(
        metadata: metadata!,
        content: content,
        resourceResolver: session.getResourceResolver(),
        initialResources: _resolvedResources,
        maxConcurrentDownloads: settings.parallelImageDownloads,
        onProgress: throttled,
        cancelToken: _cancelToken,
      );
      if (_isCancelled) return;

      resolvedBook = result.book;
      _resolvedResources = result.book.resources;
      failedTasks = result.failedTasks;

      await _convertBook();
      if (_isCancelled) return;

      progress = Progress(stage: Stages.done);
      status = DownloadTaskStatus.completed;

      logger.i('Download completed for book [${session.code}-$bookId]');
      onTaskCompleted?.call(this as DownloadTask);
    } catch (e, trace) {
      if (_isCancelled) return;
      logger.e(
        'Error downloading book [${session.code}-$bookId]',
        error: e,
        stackTrace: trace,
      );
      errorMessage = e.toString();
      progress = Progress(stage: Stages.error, message: e.toString());
      failedTasks = const [];
      status = DownloadTaskStatus.failed;
    }
  }

  @action
  void cancel() {
    _isCancelled = true;
    _cancelToken?.cancel();
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
    status = DownloadTaskStatus.downloading;
    failedTasks = [];
    try {
      final result = await BookExporter.resolveBook(
        metadata: metadata!,
        content: _contentCache!,
        resourceResolver: session.getResourceResolver(),
        initialResources: _resolvedResources,
        maxConcurrentDownloads: settings.parallelImageDownloads,
        cancelToken: _cancelToken,
        onProgress: _throttledProgress(minIntervalMs: 50),
      );
      if (_isCancelled) return;

      resolvedBook = result.book;
      _resolvedResources = result.book.resources;
      failedTasks = result.failedTasks;
      await _convertBook();
      if (_isCancelled) return;
      progress = Progress(stage: Stages.done);
      status = DownloadTaskStatus.completed;
    } catch (e, trace) {
      if (_isCancelled) return;
      logger.e('Error retrying failed images', error: e, stackTrace: trace);
      errorMessage = e.toString();
      status = DownloadTaskStatus.failed;
    }
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

  Future<void> share() async {
    if (resolvedBook == null || metadata == null) return;
    runInAction(() => isExporting = true);
    try {
      final bytes = await _encodeCurrentBook();
      await _sharer.shareBook(
        bytes: bytes,
        metadata: metadata!,
        format: saveFormat,
        portal: session.portal,
        resolvedBook: resolvedBook,
        downloadPathTemplate: settings.downloadPathTemplate,
        authorsPathSeparator: settings.authorsPathSeparator,
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
      final templateFileName = _templateFileName();
      final bytes = await _encodeCurrentBook(
        templateFileName: templateFileName,
      );
      final finalPath = await _saver.saveToFile(
        bytes: bytes,
        templateFileName: templateFileName,
        format: saveFormat,
        saveDirectory: settings.saveDirectory,
      );
      if (finalPath == null) return const ExportCancelled();
      runInAction(() => savedFilePath = finalPath);
      unawaited(
        recentBooksService.updateRecentBookFile(
          portalCode: session.portal.code,
          bookId: bookId,
          savedFilePath: finalPath,
          saveFormat: saveFormat,
          downloadedAt: DateTime.now(),
        ),
      );
      return ExportSaved(finalPath);
    } catch (e, trace) {
      logger.e('Book export error', error: e, stackTrace: trace);
      return ExportFailed(e);
    } finally {
      runInAction(() => isExporting = false);
    }
  }

  Future<void> _convertBook() async {
    if (resolvedBook == null) return;
    runInAction(() => isExporting = true);

    try {
      final templateFileName = _templateFileName();
      final bytes = await _encodeCurrentBook(
        templateFileName: templateFileName,
      );

      if (_isCancelled) return;

      final saveDirectory = settings.saveDirectory;
      if ((settings.autoSaveOnComplete || savedFilePath != null) &&
          saveDirectory != null &&
          saveDirectory.isNotEmpty) {
        final finalPath = await _saver.saveToFile(
          bytes: bytes,
          templateFileName: templateFileName,
          format: saveFormat,
          saveDirectory: saveDirectory,
        );

        if (finalPath != null) {
          runInAction(() => savedFilePath = finalPath);
          unawaited(
            recentBooksService.updateRecentBookFile(
              portalCode: session.portal.code,
              bookId: bookId,
              savedFilePath: finalPath,
              saveFormat: saveFormat,
              downloadedAt: DateTime.now(),
            ),
          );
          logger.i('Saved book to $finalPath');
        }
      } else if (!settings.autoSaveOnComplete && savedFilePath != null) {
        runInAction(() => savedFilePath = null);
      }
    } catch (e, trace) {
      logger.e('Book conversion error', error: e, stackTrace: trace);
    } finally {
      runInAction(() => isExporting = false);
    }
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

  /// Единая точка кодирования с кэшем. Раньше логика была
  /// скопирована в `_export` и `_convertBook`.
  Future<Uint8List> _encodeCurrentBook({String? templateFileName}) async {
    final format = saveFormat;
    if (templateFileName == null &&
        _encodedFormat == format &&
        _encodedBytes != null) {
      return _encodedBytes!;
    }
    final name = templateFileName ?? _templateFileName();
    final bytes = await _encoder.encode(
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

  double? get normalizedProgress => progress.normalized;
}
