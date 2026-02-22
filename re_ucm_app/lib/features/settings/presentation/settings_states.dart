import 'package:re_ucm_core/models/portal.dart';

import '../../portals/application/portal_session.cg.dart';

sealed class SettingsPageState {}

class SettingsMainPage extends SettingsPageState {
  final PortalSession<PortalSettings>? selectedSession;
  SettingsMainPage({this.selectedSession});
}

class SettingsSaveSettingsPage extends SettingsPageState {}
