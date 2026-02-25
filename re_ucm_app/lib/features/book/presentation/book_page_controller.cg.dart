import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:re_ucm_core/models/book.dart';
import 'package:re_ucm_core/models/progress.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/logger.dart';
import '../../../core/navigation/router_delegate.dart';
import '../../common/widgets/overlay_snack.dart';
import '../../converters/fb2/converter.dart';
import '../../portals/application/portal_session.cg.dart';
import '../../recent_books/application/recent_books_service.dart';
import '../../settings/application/settings_service.cg.dart';
import '../../settings/domain/path_placeholders.dart';
import '../../settings/domain/path_template.cg.dart';
import '../../settings/presentation/save_settings/tag_editing_controller.dart';

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
  });

  final String id;

  @observable
  late ObservableFuture<Book> book = ObservableFuture(_fetch());

  @action
  void fetch() => book = ObservableFuture(_fetch());

  bool get isAuthorized => session.isAuthorized;

  @action
  Future<Book> _fetch() async {
    try {
      logger.i('Fetching book metadata [${session.code}-$id]');
      final book = await session.getBook(id);
      recentBooksService.addRecentBook(book);
      return book;
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
  Uint8List? bookXmlBytes;

  @action
  Future<void> download() async {
    logger.i('Downloading book');
    isDownloading = true;
    try {
      final chapters = await session.getText(id);
      book.value!.chapters.clear();
      book.value!.chapters.addAll(chapters);

      bookXmlBytes = await convertToFB2(book.value!, (progress) {
        this.progress = progress;
        logger.i('Progress: $progress');
      });
    } catch (e, trace) {
      logger.e('Book downloading error', error: e, stackTrace: trace);
      progress = Progress(stage: Stages.error, message: e.toString());
    }
    isDownloading = false;
  }

  void share() => _export(share: true);
  void save() => _export(share: false);

  void _export({bool share = false}) async {
    var data = book.value!;
    var name = data.series != null
        ? '${data.series?.name}–${data.series?.number}'
        : data.title;

    name = name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '');

    var tempDir = (await getTemporaryDirectory()).path;
    final filePath = path.join(tempDir, '$name.fb2');
    var file = File(filePath);
    await file.writeAsBytes(bookXmlBytes!);

    try {
      final xfile = XFile(
        filePath,
        name: '$name.fb2',
        mimeType: 'application/x-fictionbook+xml',
      );

      if (share) {
        final text =
            '${data.title}'
            '\nАвторы: ${data.authors.map((e) => e.name).join(', ')}'
            '${data.series == null ? '' : '\nСерия: ${data.series!.name} #${data.series!.number}'}'
            '\n'
            '\nПо: «${data.chapters.last.title}»';

        await SharePlus.instance.share(
          ShareParams(files: [xfile], text: text, subject: name),
        );
        return;
      }

      bool isGranted = await Permission.manageExternalStorage
          .request()
          .isGranted;
      if (!isGranted) openAppSettings();

      final templateFileName = _buildTemplateFileName(data, settings);
      final saveDirectory = settings.saveDirectory;

      String? finalPath;

      if (saveDirectory != null && saveDirectory.isNotEmpty) {
        finalPath = path.join(saveDirectory, '$templateFileName.fb2');
        final file = File(finalPath);
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bookXmlBytes!);
      } else {
        finalPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Сохранение книги',
          bytes: bookXmlBytes,
          fileName: '$templateFileName.fb2',
          type: FileType.custom,
          allowedExtensions: ['fb2'],
        );
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
  }

  String _buildTemplateFileName(Book data, SettingsService settings) {
    var template = settings.downloadPathTemplate.path.trim();

    if (template.isEmpty) template = PathTemplate.initialPathPlaceholder;
    final rendered = _renderTemplate(template, data, settings).trim();

    return rendered;
  }

  String _renderTemplate(String template, Book data, SettingsService settings) {
    final separator = settings.authorsPathSeparator;
    final authorsSeparator = separator.isEmpty ? ', ' : separator;

    return template.replaceAllMapped(TagEditingController.tagRegExp, (match) {
      final label = match.group(1) ?? '';
      final placeholder = PathPlaceholders.fromLabel(label);
      if (placeholder == null) return '';
      final value = placeholder.resolve(data, authorsSeparator);
      return value.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    });
  }
}
