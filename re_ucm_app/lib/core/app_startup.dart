import 'package:material_ui/material_ui.dart';

import '../core/di.dart';
import '../core/navigation/nav.dart';
import '../features/ota/presentation/changelog_dialog.dart';
import '../features/ota/presentation/update_widget.dart';

class AppStartup {
  static bool _otaChecked = false;

  static Future<void> checkUpdates(BuildContext context) async {
    if (_otaChecked) return;
    _otaChecked = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ota = AppDependencies.of(context).otaService;
      if (await ota.getIsFirstLaunch()) {
        if (!context.mounted) return;
        await Nav.pushDialog((_, _, _) => const ChangelogDialog());
        ota.setLatestLaunchVersion();
        return;
      }
      if (await ota.checkForUpdate()) {
        if (!context.mounted) return;
        Nav.pushBottomSheet(const UpdateWidget());
      }
    });
  }
}
