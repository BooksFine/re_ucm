import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';
import 'package:zikzak_share_handler/zikzak_share_handler.dart';

import '../../core/logger.dart';
import '../../core/navigation/router.dart';
import '../../core/navigation/router_delegate.dart';
import '../common/utils/uri_from_url.dart';
import '../common/widgets/snack.dart';

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
    handler.getInitialSharedMedia().then((media) {
      if (media != null) {
        _processMedia(media);
        handler.resetInitialSharedMedia();
      }
    }).catchError((e) {
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
    });
  }

  static void _openSharedContent(String content) {
    try {
      final uri = uriFromUrl(content);
      final portal = PortalFactory.fromUrl(uri);
      final bookId = portal.service.getIdFromUrl(uri);

      Nav.book(portal.code, bookId);
    } catch (e) {
      logger.e('Failed to open shared book: $content', error: e);

      final ctx = rootNavigationKey.currentContext;
      if (ctx != null && ctx.mounted) {
        snackMessage(ctx, 'Ошибка при открытии книги: $e');
      }
    }
  }
}

@Deprecated('Use ShareReceiverService.init() instead')
Future<void> shareHandler(BuildContext context) async {
  ShareReceiverService.init();
}
