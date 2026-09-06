import 'package:dart_book/dart_book.dart';
import 'package:flutter/services.dart';
import 'package:mobx/mobx.dart';
import 'package:re_ucm_core/re_ucm_core.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../downloads/domain/download_task.cg.dart';
import '../../downloads/domain/downloads_service.cg.dart';
import 'link_parser.dart';

/// Состояние + координация LinkForwarder.
/// Намеренно без BuildContext внутри: сервисы передаются параметрами,
/// UI-решения (диалоги, модалы, haptics) остаются во view.
class LinkForwarderController {
  final Observable<bool> isEmpty = Observable(true);
  final Observable<SaveFormat?> selectedFormat = Observable(null);
  final Observable<bool> isLoadingBook = Observable(false);
  final Observable<String?> loadingError = Observable(null);
  final Observable<BookMetadata?> loadedMetadata = Observable(null);
  final Observable<Portal?> loadedPortal = Observable(null);
  final Observable<String?> loadedBookId = Observable(null);

  void onTextChanged(String value) {
    final newIsEmpty = value.trim().isEmpty;
    if (isEmpty.value != newIsEmpty) {
      runInAction(() => isEmpty.value = newIsEmpty);
    }
    if (loadedMetadata.value != null || loadingError.value != null) {
      runInAction(() {
        loadedMetadata.value = null;
        loadedPortal.value = null;
        loadedBookId.value = null;
        loadingError.value = null;
      });
    }
  }

  /// Возвращает распарсенную ссылку, если автозагрузка уместна.
  /// View сам решает, вызывать ли fetch.
  ParsedBookLink? autoFetchCandidate(String value) {
    final text = value.trim();
    if (text.isEmpty || isLoadingBook.value) return null;
    final parsed = tryParseBookLink(text);
    if (parsed == null) return null;
    if (parsed.bookId.isEmpty || parsed.bookId == loadedBookId.value) {
      return null;
    }
    return parsed;
  }

  void reset() {
    runInAction(() {
      isEmpty.value = true;
      isLoadingBook.value = false;
      loadingError.value = null;
      loadedMetadata.value = null;
      loadedPortal.value = null;
      loadedBookId.value = null;
      selectedFormat.value = null;
    });
  }

  void setSelectedFormat(SaveFormat format) {
    runInAction(() => selectedFormat.value = format);
  }

  /// Возвращает текст из буфера (или null). Haptics — во view.
  Future<String?> readClipboardText() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    return text.isEmpty ? null : text;
  }

  Future<void> fetchBookInfo({
    required ParsedBookLink link,
    required PortalSession session,
  }) async {
    runInAction(() {
      isLoadingBook.value = true;
      loadingError.value = null;
      loadedMetadata.value = null;
      loadedPortal.value = null;
      loadedBookId.value = null;
    });

    try {
      final meta = await session.getBookMetadata(link.bookId);
      runInAction(() {
        isLoadingBook.value = false;
        loadedMetadata.value = meta;
        loadedPortal.value = link.portal;
        loadedBookId.value = link.bookId;
      });
    } catch (e) {
      runInAction(() {
        isLoadingBook.value = false;
        loadingError.value = 'Не удалось загрузить данные книги: $e';
      });
    }
  }

  /// Создаёт (или переиспользует) задачу. Возвращает null, если нечего качать.
  /// Проверку auth и показ модала делает view — здесь только domain.
  DownloadTask? buildDownloadTask({
    required SettingsService settingsService,
    required DownloadsService downloadsService,
  }) {
    final meta = loadedMetadata.value;
    final portal = loadedPortal.value;
    final bookId = loadedBookId.value;
    if (meta == null || portal == null || bookId == null) return null;

    final session = settingsService.sessionByCode(portal.code);
    final format = selectedFormat.value ?? settingsService.saveFormat;
    final task = downloadsService.getOrCreateTask(
      session: session,
      bookId: bookId,
      initialMetadata: meta,
    );
    task.updateSaveFormat(format);
    if (!task.isActive) {
      task.start();
    }
    return task;
  }
}
