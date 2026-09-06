import 'package:dart_book/dart_book.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mobx/mobx.dart';
import 'package:re_ucm_core/re_ucm_core.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../core/di.dart';
import '../../common/utils/uri_from_url.dart';
import '../../downloads/domain/download_task.cg.dart';
import '../../downloads/presentation/widgets/unauthorized_download_dialog.dart';

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
    checkAndAutoFetch(value);
  }

  void checkAndAutoFetch(String value) {
    final text = value.trim();
    if (text.isEmpty || isLoadingBook.value) return;
    try {
      final uri = uriFromUrl(text);
      final portal = PortalFactory.fromUrl(uri);
      final bookId = portal.service.getIdFromUrl(uri);
      if (bookId.isNotEmpty && bookId != loadedBookId.value) {
        fetchBookInfo(text: text, validate: () => true);
      }
    } catch (_) {}
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

  Future<void> pasteFromClipboard({
    required Future<void> Function(String text) onPasted,
  }) async {
    HapticFeedback.lightImpact();
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (text.isNotEmpty) {
      await onPasted(text);
      fetchBookInfo(text: text, validate: () => true);
    }
  }

  Future<void> fetchBookInfo({
    String? text,
    required bool Function() validate,
  }) async {
    if (!validate()) return;

    final url = text?.trim() ?? '';
    final uri = uriFromUrl(url);
    final portal = PortalFactory.fromUrl(uri);
    final bookId = portal.service.getIdFromUrl(uri);

    runInAction(() {
      isLoadingBook.value = true;
      loadingError.value = null;
      loadedMetadata.value = null;
      loadedPortal.value = null;
      loadedBookId.value = null;
    });

    try {
      final ctx = _context;
      if (ctx == null) return;
      final deps = AppDependencies.of(ctx);
      final session = deps.settingsService.sessionByCode(portal.code);
      final meta = await session.getBookMetadata(bookId);

      if (!ctx.mounted) return;
      runInAction(() {
        isLoadingBook.value = false;
        loadedMetadata.value = meta;
        loadedPortal.value = portal;
        loadedBookId.value = bookId;
      });
    } catch (e) {
      final ctx = _context;
      if (ctx == null || !ctx.mounted) return;
      runInAction(() {
        isLoadingBook.value = false;
        loadingError.value = 'Не удалось загрузить данные книги: $e';
      });
    }
  }

  BuildContext? _context;
  void bindContext(BuildContext context) => _context = context;
  void unbindContext() => _context = null;

  Future<void> startDownload({
    required SaveFormat defaultFormat,
    required void Function(DownloadTask task) showModal,
  }) async {
    if (loadedMetadata.value == null ||
        loadedPortal.value == null ||
        loadedBookId.value == null) {
      return;
    }

    final ctx = _context;
    if (ctx == null || !ctx.mounted) return;

    final deps = AppDependencies.of(ctx);
    final session =
        deps.settingsService.sessionByCode(loadedPortal.value!.code);

    final shouldProceed = await checkAndConfirmUnauthorizedDownload(
      context: ctx,
      session: session,
      settingsService: deps.settingsService,
    );
    if (!shouldProceed || !ctx.mounted) return;

    final format = selectedFormat.value ?? defaultFormat;

    final task = deps.downloadsService.getOrCreateTask(
      session: session,
      bookId: loadedBookId.value!,
      initialMetadata: loadedMetadata.value,
    );
    task.updateSaveFormat(format);
    if (!task.isActive) {
      task.start();
    }

    reset();

    if (ctx.mounted) {
      showModal(task);
    }
  }
}
