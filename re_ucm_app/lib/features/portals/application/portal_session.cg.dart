import 'package:mobx/mobx.dart';
import 'package:re_ucm_core/models/book.dart';
import 'package:re_ucm_core/models/portal.dart';

part '../../../.gen/features/portals/application/portal_session.cg.g.dart';

class PortalSession<T extends PortalSettings> = PortalSessionBase<T>
    with _$PortalSession<T>;

abstract class PortalSessionBase<T extends PortalSettings> with Store {
  PortalSessionBase({
    required this.portal,
    required T initialSettings,
    required Future<void> Function(String code, Map<String, dynamic> json)
    persistCallback,
  }) : _persistCallback = persistCallback {
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
  Future<void> updateSettings(T newSettings) async {
    settings = newSettings;
    await _persistCallback(portal.code, newSettings.toJson());
  }

  Future<Book> getBook(String id) =>
      portal.service.getBookFromId(id, settings: settings);

  Future<List<Chapter>> getText(String id) =>
      portal.service.getTextFromId(id, settings: settings);
}
