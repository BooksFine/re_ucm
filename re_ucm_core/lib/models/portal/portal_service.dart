part of '../portal.dart';

abstract interface class PortalService<T extends PortalSettings> {
  T settingsFromJson(Map<String, dynamic>? json);

  List<PortalSettingItem> buildSettingsSchema(T settings);

  bool isAuthorized(T settings);

  String getIdFromUrl(Uri url);

  void Function(T updatedSettings)? onSettingsChanged;

  Future<BookMetadata> getBookMetadata(String id, {required T settings});

  Future<BookContent> getBookContent(String id, {required T settings});

  BookResourceResolver getResourceResolver(T settings);
}
