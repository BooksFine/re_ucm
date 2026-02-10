import 'package:flutter/material.dart';
import 'package:re_ucm_core/models/portal.dart';
import 'package:re_ucm_core/ui/constants.dart';
import 'package:re_ucm_core/ui/settings.dart';
import '../../../core/navigation/router_delegate.dart';
import '../../portals/presentation/portals_list.dart';
import '../application/settings_service.cg.dart';
import 'widgets/download_path_editor.dart';
import 'widgets/social_row.dart';

class Settings extends StatefulWidget {
  const Settings({super.key, required this.service});

  final SettingsService service;

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Portal? selectedPortal;
  void setSelectedPortal(Portal portal) {
    if (selectedPortal == portal) {
      selectedPortal = null;
    } else {
      selectedPortal = portal;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            primary: false,
            children: [
              const SizedBox(height: appPadding * 2),

              const SettingsTitle('Настройки'),

              const SizedBox(height: appPadding * 2),
              PortalsList(authIndication: true, onTap: setSelectedPortal),
              const SizedBox(height: appPadding / 2),

              AnimatedSize(
                duration: Durations.medium2,
                alignment: Alignment.topCenter,
                child: AnimatedSwitcher(
                  duration: Durations.long2,
                  child:
                      selectedPortal?.service.settings ??
                      Column(
                        children: [
                          SizedBox(height: appPadding * 2),

                          DownloadPathEditor(service: widget.service),
                          SizedBox(height: appPadding),
                          SettingsButton(
                            title: 'История изменений',
                            leading: const Icon(Icons.history),
                            onTap: () {
                              Nav.goChangelog();
                            },
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
