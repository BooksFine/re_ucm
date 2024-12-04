import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:re_ucm_core/models/book.dart';
import 'package:re_ucm_core/models/portal.dart';
import 'package:re_ucm_core/models/progress.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/di.dart';
import '../../../core/logger.dart';
import '../../../core/navigation/router_delegate.dart';
import '../../common/widgets/overlay_snack.dart';
import '../../converters/fb2/converter.dart';
import '../../recent_books/application/recent_books_service.dart';

part '../../../.gen/features/book/presentation/book_page_controller.cg.g.dart';

class BookPageController = BookPageControllerBase with _$BookPageController;

abstract class BookPageControllerBase with Store {
  final scaffoldKey = GlobalKey();

  BookPageControllerBase({required this.id, required this.portal});

  final String id;
  final Portal portal;

  @observable
  late ObservableFuture<Book> book = ObservableFuture(_fetch());

  @action
  void fetch() => book = ObservableFuture(_fetch());

  @action
  Future<Book> _fetch() async {
    try {
      logger.i('Fetching book metadata [${portal.code}-$id]');
      final book = await portal.service.getBookFromId(id);
      locator<RecentBooksService>().addRecentBook(book);
      return book;
    } catch (e, trace) {
      logger.e(
        'Error fetching book metadata [${portal.code}-$id]',
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
      var chapters = await portal.service.getTextFromId(id);
      book.value!.chapters.addAll(chapters);

      bookXmlBytes = await convertToFB2(
        book.value!,
        (progress) {
          this.progress = progress;
          logger.i('Progress: $progress');
        },
      );
    } catch (e, trace) {
      logger.e('Book downloading error', error: e, stackTrace: trace);
      progress = Progress(stage: Stages.error, message: e.toString());
    }
    isDownloading = false;
  }

  void share() => _export(share: true);
  void save() => _export(share: false);

  void _export({share = false}) async {
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
        final text = '${data.title}'
            '\nАвторы: ${data.authors.map((e) => e.name).join(', ')}'
            '${data.series == null ? '' : '\nСерия: ${data.series!.name} #${data.series!.number}'}'
            '\n'
            '\nПо: «${data.chapters.last.title}»';

        await Share.shareXFiles([xfile], text: text, subject: name);
        return;
      }
      bool isGranted =
          await Permission.manageExternalStorage.request().isGranted;
      if (!isGranted) openAppSettings();

      final finalPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Сохранение книги',
        fileName: '$name.fb2',
        bytes: bookXmlBytes,
        type: FileType.custom,
        allowedExtensions: ['fb2'],
      );

      if (finalPath == null) {
        return overlaySnackMessage(
          scaffoldKey.currentContext!,
          'Сохранение отменено',
        );
      }

      await xfile.saveTo(finalPath);
      overlaySnackMessage(scaffoldKey.currentContext!, 'Успешно сохранено');
    } catch (e, trace) {
      overlaySnackMessage(scaffoldKey.currentContext!, 'Произошла ошибка');
      logger.e('Error saving book', error: e, stackTrace: trace);
    } finally {
      if (!Platform.isWindows) await file.delete();
    }
  }
}
