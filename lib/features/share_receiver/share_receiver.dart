import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_handler/share_handler.dart';

import '../../core/logger.dart';
import '../../core/navigation/router_delegate.dart';
import '../common/utils/uri_from_url.dart';
import '../common/widgets/snack.dart';
import '../portals/portal.dart';
import '../portals/portal_service.dart';

Future<void> shareHandler(BuildContext context) async {
  if (!Platform.isAndroid) return;
  final handler = ShareHandlerPlatform.instance;
  var media = await handler.getInitialSharedMedia();
  if (media?.content == null) return;

  try {
    final uri = uriFromUrl(media!.content!);
    final portal = Portal.fromUrl(uri);

    Nav.book(portal.code, portal.service.getIdFromUrl(uri));
  } catch (e) {
    logger.e('Failed to open the book', error: e);

    // ignore: use_build_context_synchronously
    snackMessage(context, 'Ошибка при открытии книги: $e');
  }
}
