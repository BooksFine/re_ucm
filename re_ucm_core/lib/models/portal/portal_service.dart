import 'package:flutter/material.dart';
import 'package:re_ucm_core/models/book/book.dart';
import 'package:re_ucm_core/models/book/chapter.dart';

abstract interface class PortalService {
  Widget get settings;
  bool get isAuthorized;
  String getIdFromUrl(Uri url);
  Future<Book> getBookFromId(String id);
  Future<List<Chapter>> getTextFromId(String id);
}
