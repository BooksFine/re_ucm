import 'package:flutter/widgets.dart';
import 'package:re_ucm_core/models/book.dart';
import 'package:re_ucm_core/models/portal.dart';

import 'application/at_internal_service.dart';
import 'presentation/at_settings.dart';

class AuthorTodayService implements PortalService {
  @override
  Widget get settings => ATSettings(service: _internalService);

  @override
  bool get isAuthorized => _internalService.token != null;

  @override
  String getIdFromUrl(Uri url) {
    if (url.host != 'author.today' ||
        url.pathSegments.length != 2 ||
        !['work', 'reader'].contains(url.pathSegments[0]) ||
        int.tryParse(url.pathSegments[1]) == null) {
      throw ArgumentError('Invalid link');
    }

    return url.pathSegments[1];
  }

  @override
  Future<Book> getBookFromId(String id) => _internalService.getMeta(id);

  @override
  Future<List<Chapter>> getTextFromId(String id) =>
      _internalService.getManyTexts(id);

  AuthorTodayService._();

  static Future<AuthorTodayService> create(Portal portal) async {
    final service = AuthorTodayService._();
    service._internalService = await ATInternalService.init(portal);
    return service;
  }

  late final ATInternalService _internalService;
}
