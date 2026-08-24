import 'package:dart_book/dart_book.dart';
import 'package:mobx/mobx.dart';
import 'package:re_ucm_core/models/portal.dart';
import 'package:re_ucm_core/models/progress.dart';

part '../.gen/portals/portal_session.cg.g.dart';

class PortalSession<T extends PortalSettings> = PortalSessionBase<T>
    with _$PortalSession<T>;

abstract class PortalSessionBase<T extends PortalSettings> with Store {
  PortalSessionBase({
    required this.portal,
    required T initialSettings,
    required this._persistCallback,
  }) {
    settings = initialSettings;
    portal.service.onSettingsChanged = (s) => updateSettings(s);
  }

  final Portal<T> portal;
  final Future<void> Function(String code, Map<String, dynamic> json)
  _persistCallback;

  @observable
  late T settings;

  @computed
  bool get isAuthorized => portal.service.isAuthorized(settings);

  @computed
  List<PortalSettingItem> get schema =>
      portal.service.buildSettingsSchema(settings);

  String get url => portal.url;
  String get name => portal.name;
  String get code => portal.code;
  PortalLogo get logo => portal.logo;
  PortalService<T> get service => portal.service;

  @action
  void resetTempFlags() {
    settings = portal.service.settingsFromJson(settings.toJson());
  }

  @action
  Future<void> updateSettings(T newSettings) async {
    settings = newSettings;
    await _persistCallback(portal.code, newSettings.toJson());
  }

  Future<BookMetadata> getBookMetadata(String id) =>
      portal.service.getBookMetadata(id, settings: settings);

  Future<BookContent> getBookContent(
    String id, {
    void Function(Progress progress)? onProgress,
  }) => portal.service.getBookContent(
    id,
    settings: settings,
    onProgress: onProgress,
  );

  BookResourceResolver getResourceResolver() =>
      portal.service.getResourceResolver(settings);
}
