part of '../portal.dart';

abstract interface class PortalService<T extends PortalSettings> {
  T settingsFromJson(Map<String, dynamic>? json);

  List<PortalSettingItem> buildSettingsSchema(T settings);

  bool isAuthorized(T settings);

  String getIdFromUrl(Uri url);

  void Function(T updatedSettings)? onSettingsChanged;

  Future<Book> getBookFromId(String id, {required T settings});

  Future<List<Chapter>> getTextFromId(String id, {required T settings});
}
