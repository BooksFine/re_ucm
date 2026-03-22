import 'package:mobx/mobx.dart';
import 'package:re_ucm_core/models/portal.dart';

import 'package:re_ucm_lib/re_ucm_lib.dart';
import 'package:re_ucm_lib/settings/domain/save_format.dart';
import 'settings_states.dart';

part '../../../.gen/features/settings/presentation/settings_controller.cg.g.dart';

class SettingsController = SettingsControllerBase with _$SettingsController;

abstract class SettingsControllerBase with Store {
  final SettingsService service;

  SettingsControllerBase({required this.service});

  @observable
  SettingsPageState page = SettingsMainPage();

  @action
  void setSelectedSession(PortalSession session) {
    final current = page;

    if (current is SettingsMainPage && current.selectedSession == session) {
      page = SettingsMainPage();
    } else {
      page = SettingsMainPage(selectedSession: session);
    }
  }

  @action
  void openSaveSettings() => page = SettingsSaveSettingsPage();

  @action
  void openMain() => page = SettingsMainPage();

  PortalSession sessionByCode(String code) => service.sessionByCode(code);

  //Save settings

  SaveFormat get saveFormat => service.saveFormat;
  void updateSaveFormat(SaveFormat format) => service.updateSaveFormat(format);

  PathTemplate get downloadPathTemplate => service.downloadPathTemplate;
  void updateDownloadPathTemplate(PathTemplate template) =>
      service.updateDownloadPathTemplate(template);

  String get authorsPathSeparator => service.authorsPathSeparator;
  void updateAuthorsPathSeparator(String separator) =>
      service.updateAuthorsPathSeparator(separator);

  String? get saveDirectory => service.saveDirectory;
  void updateSaveDirectory(String? path) => service.updateSaveDirectory(path);
}
