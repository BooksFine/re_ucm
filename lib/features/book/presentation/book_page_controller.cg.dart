import 'dart:io';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/di.dart';
import '../../../core/logger.dart';
import '../../../core/navigation/router_delegate.dart';
import '../../common/widgets/snack.dart';
import '../../converters/fb2/converter.dart';
import '../../portals/portal.dart';
import '../../portals/portal_service.dart';
import '../../recent_books/application/recent_books_service.dart';
import '../domain/book.dart';
import '../domain/progress.dart';

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
        (prgrs) {
          progress = prgrs;
          logger.i('Progress: $prgrs');
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

    name = name.replaceAll('?', '');
    name = name.replaceAll(':', '');

    if (share) {
      var tempDir = await getApplicationSupportDirectory();
      final path = '${tempDir.path}/$name.fb2';
      var file = File(path);
      await file.writeAsBytes(bookXmlBytes!);

      try {
        var xfile = XFile(
          path,
          mimeType: 'application/x-fictionbook+xml',
        );

        final text = '${data.title}'
            '\nАвторы: ${data.authors.map((e) => e.name).join(', ')}'
            '${data.series == null ? '' : '\nСерия: ${data.series!.name} #${data.series!.number}'}'
            '\n'
            '\n${data.chapters.length} глав'
            '\nПо: "${data.chapters.last.title}"';

        await Share.shareXFiles([xfile], text: text, subject: text);
      } finally {
        await file.delete();
      }
    } else {
      final bool saveAs =
          Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
      final func =
          saveAs ? FileSaver.instance.saveAs : FileSaver.instance.saveFile;

      try {
        await func(
          name: name,
          ext: 'fb2',
          bytes: bookXmlBytes!,
          mimeType: MimeType.custom,
          customMimeType: 'application/x-fictionbook+xml',
        );
        if (scaffoldKey.currentContext != null && !saveAs) {
          snackMessage(
            scaffoldKey.currentContext!,
            'Книга сохранена в загрузки',
          );
        }
      } catch (e, trace) {
        logger.e('Error saving book', error: e, stackTrace: trace);
      }
    }
  }
}
