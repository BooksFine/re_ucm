import 'package:re_ucm_core/models/portal.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

sealed class SettingsPageState {}

class SettingsMainPage extends SettingsPageState {
  final PortalSession<PortalSettings>? selectedSession;
  SettingsMainPage({this.selectedSession});
}

class SettingsSaveSettingsPage extends SettingsPageState {}
