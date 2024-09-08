import 'package:flutter/material.dart';

import '../../core/di.dart';
import '../book/domain/book.dart';
import '../book/domain/chapter.dart';
import 'author.today/author_today_service.dart';
import 'portal.dart';

abstract interface class PortalService {
  Widget get settings;
  bool get isAuthorized;
  String getIdFromUrl(Uri url);
  Future<Book> getBookFromId(String id);
  Future<List<Chapter>> getTextFromId(String id);
}

extension PortalServiceExtension on Portal {
  PortalService get service {
    return locator.get<PortalService>(instanceName: code);
  }

  Future<PortalService> createService() {
    return switch (this) {
      Portal.authorToday => AuthorTodayService.create(),
      // Portal.litnet => AuthorTodayService.create(),
    };
  }
}
