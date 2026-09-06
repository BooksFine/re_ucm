import 'package:dart_book/dart_book.dart';
import 'package:flutter/services.dart';
import 'package:mobx/mobx.dart';
import 'package:re_ucm_core/re_ucm_core.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../downloads/domain/download_task.cg.dart';
import '../../downloads/domain/downloads_service.cg.dart';
import 'link_parser.dart';

/// Состояние превью ссылки для [LinkForwarder].
enum LinkForwarderViewState { idle, loading, error, loaded }

/// Состояние + координация LinkForwarder.
/// Намеренно без BuildContext внутри: сервисы передаются параметрами,
/// UI-решения (диалоги, модалы, haptics) остаются во view.
class LinkForwarderController {
  LinkForwarderController({this.clipboardReader, this.metadataLoader});

  /// Инъекция для тестов: чтение буфера без платформенного канала.
  final Future<String?> Function()? clipboardReader;

  /// Инъекция для тестов: загрузка метаданных без сети.
  /// Если задана — используется вместо `session.getBookMetadata`.
  final Future<BookMetadata> Function(String bookId)? metadataLoader;

  /// Монотонный счётчик запросов: отбрасываем устаревшие ответы,
  /// чтобы быстрый ввод не показывал чужое превью.
  int _fetchSeq = 0;

  final Observable<bool> isEmpty = Observable(true);
  final Observable<SaveFormat?> selectedFormat = Observable(null);
  final Observable<bool> isLoadingBook = Observable(false);
  final Observable<String?> loadingError = Observable(null);
  final Observable<BookMetadata?> loadedMetadata = Observable(null);
  final Observable<Portal?> loadedPortal = Observable(null);
  final Observable<String?> loadedBookId = Observable(null);

  /// Единый view-state для одного Observer+switch во view.
  /// Читает observables — вызывать только внутри Observer.
  LinkForwarderViewState get viewState {
    if (isLoadingBook.value) return LinkForwarderViewState.loading;
    if (loadingError.value != null) return LinkForwarderViewState.error;
    if (loadedMetadata.value != null && loadedPortal.value != null) {
      return LinkForwarderViewState.loaded;
    }
    return LinkForwarderViewState.idle;
  }

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
    final reader = clipboardReader;
    if (reader != null) {
      final text = ((await reader()) ?? '').trim();
      if (text.isEmpty) return null;
      return text;
    }
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    return text.isEmpty ? null : text;
  }

  /// Грузит метаданные. Возвращает `true`, если результат применён,
  /// `false` — если ответ устарел (текст уже изменился) и выброшен.
  ///
  /// Stale-guard: после await сверяем текущий текст view
  /// ([currentTextReader]) с загруженным bookId — чужое превью
  /// не показываем. View при `false` может повторить фетч для
  /// актуального текста, чтобы повторный ввод не терялся.
  Future<bool> fetchBookInfo({
    required ParsedBookLink link,
    required PortalSession session,
    String? Function()? currentTextReader,
  }) async {
    final seq = ++_fetchSeq;
    runInAction(() {
      isLoadingBook.value = true;
      loadingError.value = null;
      loadedMetadata.value = null;
      loadedPortal.value = null;
      loadedBookId.value = null;
    });

    try {
      final loader = metadataLoader ?? session.getBookMetadata;
      final meta = await loader(link.bookId);
      // Проиграли гонку более новому запросу — молча выходим,
      // observables трогать нельзя (их уже перезаписал новый фетч).
      if (seq != _fetchSeq) return false;
      // Текст изменился, пока грузили — чужое превью не показываем.
      final current = currentTextReader?.call();
      if (current != null &&
          tryParseBookLink(current)?.bookId != link.bookId) {
        runInAction(() {
          isLoadingBook.value = false;
        });
        return false;
      }
      runInAction(() {
        isLoadingBook.value = false;
        loadedMetadata.value = meta;
        loadedPortal.value = link.portal;
        loadedBookId.value = link.bookId;
      });
      return true;
    } catch (e) {
      if (seq != _fetchSeq) return false;
      runInAction(() {
        isLoadingBook.value = false;
        loadingError.value = _friendlyMetadataError(e);
      });
      return true;
    }
  }

  /// Создаёт (или переиспользует) задачу. Возвращает null, если нечего качать.
  /// Чистая операция: только domain, без старта.
  /// Старт делает view отдельным вызовом `task.start()`,
  /// проверку auth и показ модала — тоже view.
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
    return task;
  }
}

/// Дружелюбный текст ошибки без `Exception: ...` наружу.
String _friendlyMetadataError(Object e) {
  var detail = e
      .toString()
      .replaceFirst(RegExp(r'^(Exception|FormatException)\s*:\s*'), '')
      .trim();
  if (detail.isEmpty) {
    return 'Не удалось загрузить данные книги. Попробуйте ещё раз.';
  }
  if (detail.length > 200) detail = '${detail.substring(0, 200)}…';
  return 'Не удалось загрузить данные книги. $detail';
}
