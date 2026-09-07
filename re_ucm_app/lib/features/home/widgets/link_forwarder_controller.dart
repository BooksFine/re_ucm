import 'package:dart_book/dart_book.dart';
import 'package:flutter/services.dart';
import 'package:mobx/mobx.dart';
import 'package:re_ucm_core/re_ucm_core.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../common/utils/book_link_parser.dart';

/// Состояние превью ссылки для [LinkForwarder].
sealed class LinkForwarderState {
  const LinkForwarderState();
}

final class LinkForwarderIdle extends LinkForwarderState {
  const LinkForwarderIdle();
}

final class LinkForwarderLoading extends LinkForwarderState {
  const LinkForwarderLoading();
}

final class LinkForwarderLoaded extends LinkForwarderState {
  const LinkForwarderLoaded({
    required this.metadata,
    required this.portal,
    required this.bookId,
  });

  final BookMetadata metadata;
  final Portal portal;
  final String bookId;
}

final class LinkForwarderError extends LinkForwarderState {
  const LinkForwarderError(this.message);

  final String message;
}

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

  final Observable<LinkForwarderState> state = Observable(
    const LinkForwarderIdle(),
  );
  final Observable<bool> isEmpty = Observable(true);
  final Observable<SaveFormat?> selectedFormat = Observable(null);

  bool get isLoading => state.value is LinkForwarderLoading;

  LinkForwarderLoaded? get loadedState => switch (state.value) {
    final LinkForwarderLoaded loaded => loaded,
    _ => null,
  };

  BookMetadata? get loadedMetadata => loadedState?.metadata;
  Portal? get loadedPortal => loadedState?.portal;
  String? get loadedBookId => loadedState?.bookId;
  String? get loadingError => switch (state.value) {
    final LinkForwarderError error => error.message,
    _ => null,
  };

  void onTextChanged(String value) {
    final newIsEmpty = value.trim().isEmpty;
    if (isEmpty.value != newIsEmpty) {
      runInAction(() => isEmpty.value = newIsEmpty);
    }
    final current = state.value;
    if (current is LinkForwarderLoaded) {
      final parsed = tryParseBookLink(value);
      if (parsed == null || parsed.bookId != current.bookId) {
        _fetchSeq++;
        runInAction(() => state.value = const LinkForwarderIdle());
      }
    } else if (current is LinkForwarderError) {
      runInAction(() => state.value = const LinkForwarderIdle());
    }
  }

  /// Возвращает распарсенную ссылку, если автозагрузка уместна.
  /// View сам решает, вызывать ли fetch.
  ParsedBookLink? autoFetchCandidate(String value) {
    final text = value.trim();
    if (text.isEmpty || isLoading) return null;
    final parsed = tryParseBookLink(text);
    if (parsed == null) return null;
    if (parsed.bookId.isEmpty || parsed.bookId == loadedBookId) {
      return null;
    }
    return parsed;
  }

  void reset() {
    _fetchSeq++;
    runInAction(() {
      isEmpty.value = true;
      state.value = const LinkForwarderIdle();
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
      return text.isEmpty ? null : text;
    }
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    return text.isEmpty ? null : text;
  }

  /// Загрузка метаданных книги.
  /// Возвращает `true`, если результат применён, `false` — если запрос был отменён/устарел.
  Future<bool> fetchBookInfo({
    required ParsedBookLink link,
    required PortalSession session,
  }) async {
    final seq = ++_fetchSeq;
    runInAction(() {
      state.value = const LinkForwarderLoading();
    });

    try {
      final loader = metadataLoader ?? session.getBookMetadata;
      final meta = await loader(link.bookId);
      if (seq != _fetchSeq) return false;
      runInAction(() {
        state.value = LinkForwarderLoaded(
          metadata: meta,
          portal: link.portal,
          bookId: link.bookId,
        );
      });
      return true;
    } catch (e) {
      if (seq != _fetchSeq) return false;
      runInAction(() {
        state.value = LinkForwarderError(_friendlyMetadataError(e));
      });
      return true;
    }
  }

  void dispose() {
    _fetchSeq++;
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
