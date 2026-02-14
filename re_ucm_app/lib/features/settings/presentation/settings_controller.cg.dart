import 'package:mobx/mobx.dart';
import 'package:re_ucm_core/models/portal.dart';

import '../../portals/application/portal_session.cg.dart';
import '../application/settings_service.cg.dart';

part '../../../.gen/features/settings/presentation/settings_controller.cg.g.dart';

class SettingsController = SettingsControllerBase with _$SettingsController;

abstract class SettingsControllerBase with Store {
  final SettingsService service;

  SettingsControllerBase({required this.service});

  @observable
  PortalSession<PortalSettings>? selectedSession;

  @action
  void setSelectedSession(PortalSession session) {
    if (selectedSession == session) {
      selectedSession = null;
    } else {
      selectedSession = session;
    }
  }
}
