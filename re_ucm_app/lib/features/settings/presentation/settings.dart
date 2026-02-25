import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../core/navigation/router_delegate.dart';
import '../../../core/ui/constants.dart';
import '../../../core/ui/settings.dart';
import '../../portals/presentation/portals_list.dart';
import '../application/settings_service.cg.dart';
import 'settings_controller.cg.dart';
import 'settings_states.dart';
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
    return Observer(
      builder: (_) {
        final bool isSubPage = controller.page is! SettingsMainPage;

        return PopScope(
          canPop: !isSubPage,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) controller.openMain();
          },
          child: Material(
            type: .transparency,
            child: Stack(
              children: [
                AnimatedSize(
                  duration: Durations.medium2,
                  alignment: .topCenter,
                  child: ListView(
                    padding: .zero,
                    shrinkWrap: true,
                    primary: false,
                    children: [
                      const SizedBox(height: appPadding * 2),
                      SettingsTitle(switch (controller.page) {
                        SettingsMainPage() => 'Настройки',
                        SettingsSaveSettingsPage() => 'Настройки сохранения',
                      }),
                      SettingsAnimatedSwitcher(
                        child: switch (controller.page) {
                          SettingsMainPage v => _SettingsMainPage(
                            page: v,
                            controller: controller,
                          ),
                          SettingsSaveSettingsPage() =>
                            _SettingsSaveSettingsPage(controller: controller),
                        },
                      ),
                      const SizedBox(height: appPadding * 2),
                    ],
                  ),
                ),

                SettingsAnimatedSwitcher(
                  child: isSubPage
                      ? InkResponse(
                          radius: 24,
                          highlightColor: Colors.transparent,
                          onTap: controller.openMain,
                          child: Padding(
                            padding: EdgeInsets.all(appPadding * 2),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              size: 24,
                              color: ColorScheme.of(context).onSurfaceVariant,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                Positioned(
                  top: 0,
                  right: 0,
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
          ),
        );
      },
    );
  }
}

class _SettingsMainPage extends StatelessWidget {
  const _SettingsMainPage({required this.page, required this.controller});

  final SettingsMainPage page;
  final SettingsController controller;

  static final plkey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        PortalsList(
          key: plkey,
          authIndication: true,
          onTap: (portal) => controller.setSelectedSession(
            controller.sessionByCode(portal.code),
          ),
          isAuthorizedResolver: (portal) =>
              controller.sessionByCode(portal.code).isAuthorized,
        ),
        const SizedBox(height: appPadding / 2),
        SettingsAnimatedSwitcher(
          child: page.selectedSession != null
              ? PortalSettingsFrame(
                  key: ValueKey('settings_${page.selectedSession!.code}'),
                  session: page.selectedSession!,
                )
              : Column(
                  key: const ValueKey('global_settings'),
                  children: [
                    SettingsButton(
                      title: 'Настройки сохранения',
                      leading: const Icon(Icons.save_as_outlined),
                      onTap: controller.openSaveSettings,
                    ),
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
      ],
    );
  }
}

class _SettingsSaveSettingsPage extends StatelessWidget {
  const _SettingsSaveSettingsPage({required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        const SizedBox(height: appPadding * 4),
        DownloadPathEditor(controller: controller),
      ],
    );
  }
}
