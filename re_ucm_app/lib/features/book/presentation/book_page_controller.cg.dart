import 'dart:io';

import 'package:dart_book/dart_book.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:re_ucm_core/models/progress.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';
import 'package:re_ucm_lib/settings/domain/save_format.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants.dart';
import '../../../core/logger.dart';
import '../../../core/navigation/router_delegate.dart';
import '../../common/widgets/overlay_snack.dart';

part '../../../.gen/features/book/presentation/book_page_controller.cg.g.dart';

class BookPageController = BookPageControllerBase with _$BookPageController;

abstract class BookPageControllerBase with Store {
  final scaffoldKey = GlobalKey();
  final SettingsService settings;
  final PortalSession session;
  final RecentBooksService recentBooksService;

  BookPageControllerBase({
    required this.id,
    required this.session,
    required this.settings,
    required this.recentBooksService,
  }) : saveFormat = settings.saveFormat;

  final String id;

  @observable
  late ObservableFuture<BookMetadata> book = ObservableFuture(_fetch());

  @action
  void fetch() => book = ObservableFuture(_fetch());

  bool get isAuthorized => session.isAuthorized;

  @action
  Future<BookMetadata> _fetch() async {
    try {
      logger.i('Fetching book metadata [${session.code}-$id]');
      final metadata = await session.getBookMetadata(id);
      recentBooksService.addRecentBook(metadata, session.portal);
      return metadata;
    } catch (e, trace) {
      logger.e(
        'Error fetching book metadata [${session.code}-$id]',
        error: e,
        stackTrace: trace,
      );
      rethrow;
    }
  }

  //// Back button logic

  @computed
  bool get canPop => !isDownloading;

  void pop() {
    if (canPop) Nav.back();
  }

  //// Download logic

  @observable
  bool isDownloading = false;

  @observable
  Progress progress = Progress(stage: Stages.none);

  @observable
  Book? resolvedBook;

  @observable
  List<ImageDownloadTask> failedTasks = [];

  @observable
  SaveFormat saveFormat;

  List<BookResource> _resolvedResources = [];
  BookContent? _contentCache;

  @action
  void updateSaveFormat(SaveFormat format) {
    saveFormat = format;
    settings.updateSaveFormat(format);
  }

  @action
  Future<void> download() async {
    logger.i('Downloading book');
    isDownloading = true;
    try {
      final content = _contentCache ??= await session.getBookContent(
        id,
        onProgress: (p) {
          progress = p;
          logger.i('Chapter Progress: $p');
        },
      );

      final result = await BookExporter.resolveBook(
        metadata: book.value!,
        content: content,
        resourceResolver: session.getResourceResolver(),
        initialResources: _resolvedResources,
        onProgress: (p) {
          progress = p;
          logger.i('Progress: $p');
        },
      );

      resolvedBook = result.book;
      _resolvedResources = result.book.resources;
      failedTasks = result.failedTasks;
      progress = Progress(stage: Stages.done);
    } catch (e, trace) {
      logger.e('Book downloading error', error: e, stackTrace: trace);
      progress = Progress(stage: Stages.error, message: e.toString());
      failedTasks = const [];
    }
    isDownloading = false;
  }

  void share() => _export(share: true);
  void save() => _export(share: false);

  @action
  Future<void> _export({bool share = false}) async {
    if (resolvedBook == null) return;
    isDownloading = true;
    try {
      final data = book.value!;
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
        settings,
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
          logger.i('Progress: $p');
        },
      );

      var tempDir = (await getTemporaryDirectory()).path;
      final filePath = path.join(tempDir, '$name$ext');
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      try {
        final xfile = XFile(filePath, name: '$name$ext', mimeType: mimeType);

        if (share) {
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

        bool isGranted = await Permission.manageExternalStorage
            .request()
            .isGranted;
        if (!isGranted) openAppSettings();

        final saveDirectory = settings.saveDirectory;

        String? finalPath;

        if (saveDirectory != null && saveDirectory.isNotEmpty) {
          finalPath = path.join(saveDirectory, '$templateFileName$ext');
          final file = File(finalPath);
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes);
        } else {
          final cleanExt = ext.startsWith('.') ? ext.substring(1) : ext;
          final savedUri = await FilePicker.saveFile(
            dialogTitle: 'Сохранение книги',
            bytes: bytes,
            fileName: '$templateFileName$ext',
            type: FileType.custom,
            allowedExtensions: [cleanExt],
          );
          finalPath = savedUri != null ? (savedUri.isScheme('file') ? savedUri.toFilePath() : savedUri.toString()) : null;
        }

        if (finalPath == null) {
          return overlaySnackMessage(
            scaffoldKey.currentContext!,
            'Сохранение отменено',
          );
        }

        overlaySnackMessage(scaffoldKey.currentContext!, 'Успешно сохранено');
      } catch (e, trace) {
        overlaySnackMessage(scaffoldKey.currentContext!, 'Произошла ошибка');
        logger.e('Error saving book', error: e, stackTrace: trace);
      } finally {
        if (!Platform.isWindows) await file.delete();
      }
    } catch (e, trace) {
      logger.e('Book encoding error', error: e, stackTrace: trace);
      progress = Progress(stage: Stages.error, message: e.toString());
    } finally {
      isDownloading = false;
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
