import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../core/navigation/router_delegate.dart';
import '../../../core/ui/constants.dart';
import '../../../core/ui/settings.dart';
import '../../portals/presentation/portals_list.dart';
import '../application/settings_service.cg.dart';
import 'settings_controller.cg.dart';
import 'widgets/download_path_editor.dart';
import 'widgets/portal_settings_frame.dart';
import 'widgets/settings_animated_switcher.dart';
import 'widgets/social_row.dart';

class Settings extends StatefulWidget {
  const Settings({super.key, required this.service});

  final SettingsService service;

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late final controller = SettingsController(service: widget.service);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Observer(
            builder: (_) => ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              primary: false,
              children: [
                const SizedBox(height: appPadding * 2),

                const SettingsTitle('Настройки'),

                const SizedBox(height: appPadding * 2),
                PortalsList(
                  authIndication: true,
                  onTap: (portal) => controller.setSelectedSession(
                    widget.service.sessionByCode(portal.code),
                  ),
                  isAuthorizedResolver: (portal) =>
                      widget.service.sessionByCode(portal.code).isAuthorized,
                ),
                const SizedBox(height: appPadding / 2),

                AnimatedSize(
                  duration: Durations.medium2,
                  alignment: .topCenter,
                  child: SettingsAnimatedSwitcher(
                    child: controller.selectedSession != null
                        ? PortalSettingsFrame(
                            key: ValueKey(
                              'settings_${controller.selectedSession!.code}',
                            ),
                            session: controller.selectedSession!,
                          )
                        : Column(
                            key: const ValueKey('global_settings'),
                            children: [
                              SizedBox(height: appPadding * 2),
                              DownloadPathEditor(service: widget.service),
                              SizedBox(height: appPadding),
                              SettingsButton(
                                title: 'История изменений',
                                leading: const Icon(Icons.history),
                                onTap: Nav.goChangelog,
                              ),

                              const SizedBox(height: appPadding),
                              SocialRow(),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: appPadding * 2),
              ],
            ),
          ),
          Align(
            heightFactor: 1,
            alignment: Alignment.centerRight,
            child: InkResponse(
              radius: 24,
              highlightColor: Colors.transparent,
              onTap: Nav.back,
              child: Padding(
                padding: EdgeInsets.all(appPadding * 2),
                child: Icon(
                  Icons.close,
                  size: 24,
                  color: ColorScheme.of(context).onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
