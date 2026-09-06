import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_book/dart_book.dart';
import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobx/mobx.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:re_ucm_core/re_ucm_core.dart' hide logger;
import 'package:re_ucm_lib/re_ucm_lib.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants.dart';
import '../../../core/logger.dart';
import '../../common/widgets/overlay_snack.dart';

part '../../../.gen/features/downloads/domain/download_task.cg.g.dart';

enum DownloadTaskStatus {
  idle,
  fetchingMetadata,
  downloading,
  completed,
  failed,
  cancelled,
}

class DownloadTask = DownloadTaskBase with _$DownloadTask;

abstract class DownloadTaskBase with Store {
  final String bookId;
  final PortalSession session;
  final SettingsService settings;
  final RecentBooksService recentBooksService;
  final void Function(DownloadTask task)? onTaskCompleted;

  DownloadTaskBase({
    required this.bookId,
    required this.session,
    required this.settings,
    required this.recentBooksService,
    this.onTaskCompleted,
    BookMetadata? initialMetadata,
  }) : metadata = initialMetadata,
       saveFormat = settings.saveFormat;

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

  bool isModalOpen = false;
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

      var lastProgressTimestamp = 0;
      var lastStage = Stages.none;
      var lastCurrent = -1;

      void handleProgress(Progress p) {
        if (_isCancelled) return;
        final now = DateTime.now().millisecondsSinceEpoch;
        final isStageChanged = p.stage != lastStage;
        final isCountChanged = p.current != lastCurrent;
        final isDoneOrError = p.stage == Stages.done || p.stage == Stages.error;

        if (isDoneOrError ||
            isStageChanged ||
            isCountChanged ||
            (now - lastProgressTimestamp > 33)) {
          lastProgressTimestamp = now;
          lastStage = p.stage;
          lastCurrent = p.current ?? -1;
          progress = p;
        }
      }

      final content = _contentCache ??= await session.getBookContent(
        bookId,
        onProgress: handleProgress,
        cancelToken: _cancelToken,
      );
      if (_isCancelled) return;

      final result = await BookExporter.resolveBook(
        metadata: metadata!,
        content: content,
        resourceResolver: session.getResourceResolver(),
        initialResources: _resolvedResources,
        maxConcurrentDownloads: settings.parallelImageDownloads,
        onProgress: handleProgress,
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
      var lastRetryTimestamp = 0;
      final result = await BookExporter.resolveBook(
        metadata: metadata!,
        content: _contentCache!,
        resourceResolver: session.getResourceResolver(),
        initialResources: _resolvedResources,
        maxConcurrentDownloads: settings.parallelImageDownloads,
        cancelToken: _cancelToken,
        onProgress: (p) {
          if (_isCancelled) return;
          final now = DateTime.now().millisecondsSinceEpoch;
          if (p.stage == Stages.done ||
              p.stage == Stages.error ||
              now - lastRetryTimestamp > 50) {
            lastRetryTimestamp = now;
            progress = p;
          }
        },
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
      status = DownloadTaskStatus.completed;
    }
  }

  Future<void> share() => _export(share: true);

  Future<void> save(BuildContext context) =>
      _export(context: context, share: false);

  Future<void> _export({BuildContext? context, bool share = false}) async {
    if (resolvedBook == null || metadata == null) return;
    runInAction(() => isExporting = true);

    try {
      final data = metadata!;
      final primarySeries = data.primarySeries;
      var name = primarySeries != null
          ? '${primarySeries.name}–${primarySeries.number}'
          : data.title;

      name = name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '');

      final format = saveFormat;
      final ext = format.ext;
      final mimeType = format.mimeType;

      final templateFileName = TemplateFormatter.buildTemplateFileName(
        data,
        session.portal,
        downloadPathTemplate: settings.downloadPathTemplate,
        authorsPathSeparator: settings.authorsPathSeparator,
      );

      final Uint8List bytes;
      if (_encodedFormat == format && _encodedBytes != null) {
        bytes = _encodedBytes!;
      } else {
        bytes = await BookExporter.encode(
          book: resolvedBook!,
          format: format,
          options: BookEncodingOptions(
            documentId: 'UCM-${session.portal.code.toUpperCase()}-${data.id}',
            programUsed: 'ReUltimateCopyManager $appVersion',
            entryFilename: templateFileName,
            namingPolicy: BookResourceNamingPolicy.sequential,
          ),
          onProgress: (p) {
            progress = p;
          },
        );
        _encodedBytes = bytes;
        _encodedFormat = format;
      }

      if (share) {
        final tempDir = (await getTemporaryDirectory()).path;
        final filePath = path.join(tempDir, '$name$ext');
        final tempFile = File(filePath);
        await tempFile.writeAsBytes(bytes);

        final xfile = XFile(filePath, name: '$name$ext', mimeType: mimeType);

        final authors = data.contributors
            .map((e) => e.name.toDisplayString())
            .join(', ');

        String statusText;
        if (data.isFinished) {
          statusText = '\n\nПолностью';
        } else {
          final sections =
              resolvedBook?.content.blocks.whereType<BookSection>().toList() ??
              const [];
          final lastChapter = sections.length > 1
              ? sections[sections.length - 2]
              : (sections.isNotEmpty ? sections.first : null);
          final lastTitle = lastChapter != null
              ? _inlinesToPlainText(lastChapter.title).trim()
              : '';
          statusText = lastTitle.isNotEmpty ? '\n\nПо: «$lastTitle»' : '';
        }

        final text =
            '${data.title}'
            '\nАвторы: $authors'
            '${data.primarySeries == null ? '' : '\nСерия: ${data.primarySeries!.name} #${data.primarySeries!.number}'}'
            '$statusText';

        await SharePlus.instance.share(
          ShareParams(files: [xfile], text: text, subject: name),
        );
        return;
      }

      final saveDirectory = settings.saveDirectory;
      String? finalPath;

      if (saveDirectory != null && saveDirectory.isNotEmpty) {
        finalPath = path.join(saveDirectory, '$templateFileName$ext');
        final destFile = File(finalPath);
        await destFile.parent.create(recursive: true);
        await destFile.writeAsBytes(bytes);
      } else {
        final cleanExt = ext.startsWith('.') ? ext.substring(1) : ext;
        final savedUri = await FilePicker.saveFile(
          dialogTitle: 'Сохранение книги',
          bytes: bytes,
          fileName: '$templateFileName$ext',
          type: FileType.custom,
          allowedExtensions: [cleanExt],
        );
        finalPath = savedUri != null
            ? (savedUri.isScheme('file')
                  ? savedUri.toFilePath()
                  : savedUri.toString())
            : null;
      }

      if (context != null && context.mounted) {
        if (finalPath == null) {
          overlaySnackMessage(context, 'Сохранение отменено');
        } else {
          runInAction(() => savedFilePath = finalPath);
          unawaited(
            recentBooksService.updateRecentBookFile(
              portalCode: session.portal.code,
              bookId: bookId,
              savedFilePath: finalPath,
              saveFormat: format,
              downloadedAt: DateTime.now(),
            ),
          );
          overlaySnackMessage(context, 'Успешно сохранено');
        }
      }
    } catch (e, trace) {
      logger.e('Book export error', error: e, stackTrace: trace);
      if (context != null && context.mounted) {
        overlaySnackMessage(context, 'Произошла ошибка при сохранении');
      }
    } finally {
      runInAction(() => isExporting = false);
    }
  }

  Future<void> _convertBook() async {
    if (resolvedBook == null) return;
    runInAction(() => isExporting = true);

    try {
      final data = metadata ?? resolvedBook!.metadata;
      final format = saveFormat;
      final ext = format.ext;

      final templateFileName = TemplateFormatter.buildTemplateFileName(
        data,
        session.portal,
        downloadPathTemplate: settings.downloadPathTemplate,
        authorsPathSeparator: settings.authorsPathSeparator,
      );

      final bytes = await BookExporter.encode(
        book: resolvedBook!,
        format: format,
        options: BookEncodingOptions(
          documentId: 'UCM-${session.portal.code.toUpperCase()}-${data.id}',
          programUsed: 'ReUltimateCopyManager $appVersion',
          entryFilename: templateFileName,
          namingPolicy: BookResourceNamingPolicy.sequential,
        ),
        onProgress: (p) {
          progress = p;
        },
      );

      if (_isCancelled) return;

      _encodedBytes = bytes;
      _encodedFormat = format;

      final saveDirectory = settings.saveDirectory;
      if ((settings.autoSaveOnComplete || savedFilePath != null) &&
          saveDirectory != null &&
          saveDirectory.isNotEmpty) {
        final finalPath = path.join(saveDirectory, '$templateFileName$ext');
        final destFile = File(finalPath);
        await destFile.parent.create(recursive: true);
        await destFile.writeAsBytes(bytes);

        runInAction(() => savedFilePath = finalPath);
        unawaited(
          recentBooksService.updateRecentBookFile(
            portalCode: session.portal.code,
            bookId: bookId,
            savedFilePath: finalPath,
            saveFormat: format,
            downloadedAt: DateTime.now(),
          ),
        );
        logger.i('Saved book to $finalPath');
      } else if (!settings.autoSaveOnComplete && savedFilePath != null) {
        runInAction(() => savedFilePath = null);
      }
    } catch (e, trace) {
      logger.e('Book conversion error', error: e, stackTrace: trace);
    } finally {
      runInAction(() => isExporting = false);
    }
  }

  String _inlinesToPlainText(List<BookInline> inlines) {
    final buffer = StringBuffer();
    for (final inline in inlines) {
      switch (inline) {
        case BookText t:
          buffer.write(t.text);
        case BookEmphasis e:
          buffer.write(_inlinesToPlainText(e.children));
        case BookStrong s:
          buffer.write(_inlinesToPlainText(s.children));
        case BookStrike st:
          buffer.write(_inlinesToPlainText(st.children));
        case BookNamedStyle n:
          buffer.write(_inlinesToPlainText(n.inlines));
        case BookLink l:
          buffer.write(_inlinesToPlainText(l.children));
        case BookSuperscript sup:
          buffer.write(_inlinesToPlainText(sup.children));
        case BookSubscript sub:
          buffer.write(_inlinesToPlainText(sub.children));
        default:
          break;
      }
    }
    return buffer.toString();
  }
}
