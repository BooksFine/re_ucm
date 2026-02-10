part of '../portal.dart';

abstract interface class PortalService {
  Widget get settings;
  bool get isAuthorized;
  String getIdFromUrl(Uri url);
  Future<Book> getBookFromId(String id);
  Future<List<Chapter>> getTextFromId(String id);
}
