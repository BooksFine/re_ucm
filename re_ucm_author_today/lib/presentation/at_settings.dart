import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:re_ucm_core/ui/constants.dart';
import 'package:re_ucm_core/ui/settings.dart';

import '../application/at_internal_service.dart';
import 'at_settings_controller.cg.dart';

class ATSettings extends StatefulWidget {
  const ATSettings({super.key, required this.service});

  final ATInternalService service;

  @override
  State<ATSettings> createState() => _ATSettingsState();
}

class _ATSettingsState extends State<ATSettings> {
  late final ATSettingsController controller =
      ATSettingsController(widget.service);

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Column(
        key: controller.key,
        children: [
          const SettingsTitle('Author.Today'),
          const SizedBox(height: appPadding),
          if (controller.isAuthorized)
            SettingsButton(
              onTap: controller.logout,
              title: 'Выйти из аккаунта',
              subtitle: 'Вы залогинены как id${controller.userId}',
              trailing: const Icon(Icons.logout),
            )
          else
            SettingsButton(
              onTap: controller.webAuth,
              title: 'Вход через web',
              trailing: const Icon(Icons.login),
            ),
          if (!controller.isAuthorized)
            Observer(
              builder: (context) {
                late final Widget child;

                if (controller.isTokenAuthActive) {
                  child = SettingsTextField(
                    hint: 'Вставьте токен',
                    onTap: controller.tokenAuth,
                    isLoading: controller.isTokenAuthLoading,
                    controller: controller.tokenTextController,
                  );
                } else {
                  child = SettingsButton(
                    onTap: controller.startTokenAuth,
                    title: 'Вход с помощью токена',
                    trailing: const Icon(Icons.login),
                  );
                }

                return AnimatedSwitcher(
                  duration: Durations.medium2,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                  child: child,
                );
              },
            ),
        ],
      );
    });
  }
}
