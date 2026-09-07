import 'dart:async';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:zikzak_share_handler/zikzak_share_handler.dart';

import '../../core/di.dart';
import '../../core/logger.dart';
import '../../core/navigation/router.dart';
import '../../core/ui/tokens.dart';
import '../common/utils/book_link_parser.dart';
import '../common/widgets/snack.dart';
import '../downloads/presentation/download_modal.dart';

class ShareReceiverService {
  static StreamSubscription<SharedMedia>? _subscription;
  static String? _lastHandledContent;

  static void init() {
    if (!Platform.isAndroid) return;

    final handler = ShareHandlerPlatform.instance;

    // 1. Listen for shares while app is already running / in background
    _subscription?.cancel();
    _subscription = handler.sharedMediaStream.listen((SharedMedia media) {
      _processMedia(media);
    });

    // 2. Handle cold start share
    handler
        .getInitialSharedMedia()
        .then((media) {
          if (media != null) {
            _processMedia(media);
            handler.resetInitialSharedMedia();
          }
        })
        .catchError((e) {
          logger.e('Failed to get initial shared media', error: e);
        });
  }

  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }

  static void _processMedia(SharedMedia media) {
    final content = media.content?.trim();
    if (content == null || content.isEmpty) return;

    // Avoid duplicate execution for the same incoming intent
    if (_lastHandledContent == content) return;
    _lastHandledContent = content;

    // Schedule navigation after the current frame to ensure Navigator is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openSharedContent(content);
      // Reset dedup after processing so the same link can be re-shared later.
      if (_lastHandledContent == content) _lastHandledContent = null;
    });
  }

  static void _openSharedContent(String content) {
    // Единый парсинг через tryParseBookLink (trim/empty-bookId внутри).
    final link = tryParseBookLink(content);
    final ctx = rootNavigationKey.currentContext;
    if (ctx == null || !ctx.mounted) return;
    if (link == null) {
      AppSnack.show(
        ctx,
        'Неподдерживаемая ссылка',
        margin: EdgeInsets.symmetric(
          vertical: AppSpacing.sm * 2 + MediaQuery.paddingOf(ctx).bottom,
          horizontal: AppSpacing.sm * 2,
        ),
      );
      return;
    }

    try {
      final session = AppDependencies.of(
        ctx,
      ).settingsService.sessionByCode(link.portal.code);
      showDownloadModal(ctx, session: session, bookId: link.bookId);
    } catch (e) {
      logger.e('Failed to open shared book: $content', error: e);

      final ctx2 = rootNavigationKey.currentContext;
      if (ctx2 != null && ctx2.mounted) {
        AppSnack.show(
          ctx2,
          'Не удалось открыть книгу',
          margin: EdgeInsets.symmetric(
            vertical: AppSpacing.sm * 2 + MediaQuery.paddingOf(ctx2).bottom,
            horizontal: AppSpacing.sm * 2,
          ),
        );
      }
    }
  }
}
