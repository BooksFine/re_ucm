import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../core/constants.dart';
import '../../../core/navigation/router_delegate.dart';
import '../../portals/portal.dart';
import '../../portals/portal_service.dart';
import '../../portals/presentation/portals_list.dart';
import 'settings_button.dart';
import 'settings_title.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Portal? selectedPortal;
  setSelectedPortal(Portal portal) {
    if (selectedPortal == portal) {
      selectedPortal = null;
    } else {
      selectedPortal = portal;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: appPadding,
        vertical: appPadding,
      ),
      shrinkWrap: true,
      primary: false,
      children: [
        const SizedBox(height: appPadding),
        const SettingsTitle('Настройки'),

        const SizedBox(height: appPadding * 2),
        PortalsList(authIndication: true, onTap: setSelectedPortal),
        const SizedBox(height: appPadding * 2),

        AnimatedSize(
          duration: Durations.medium2,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: Durations.long2,
            child: selectedPortal?.service.settings ??
                Column(
                  children: [
                    const SettingsTitle('Общие'),
                    const SizedBox(height: appPadding),
                    SettingsButton(
                      title: 'История изменений',
                      leading: const Icon(Icons.history),
                      onTap: () {
                        Nav.back();
                        Nav.goChangelog();
                      },
                    ),
                    SettingsButton(
                      title: 'Telegram',
                      leading: const Icon(Icons.telegram),
                      onTap: () => launchUrlString(
                        telegramUrl,
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                  ],
                ),
          ),
        ),
        const SizedBox(height: appPadding),

        // AnimatedSize(
        //   alignment: Alignment.topCenter,
        //   duration: Durations.short4,
        //   child: Observer(builder: (_) {
        //     if (controller.serviceIndex == null) {
        //       return const SizedBox(width: double.infinity);
        //     }
        //     return controller.portals[controller.serviceIndex!].settings;
        //   }),
        // ),
      ],
    );
  }
}
