import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mobx/mobx.dart';
import 'package:re_ucm_core/re_ucm_core.dart';

import '../application/at_internal_service.dart';
import '../domain/constants.dart';

part '../.gen/presentation/at_settings_controller.cg.g.dart';

class ATSettingsController = ATSettingsControllerBase
    with _$ATSettingsController;

abstract class ATSettingsControllerBase with Store {
  late final ATInternalService service;

  String? get userId => service.userId;

  ATSettingsControllerBase(this.service);

  @computed
  bool get isAuthorized => service.token != null;

  final tokenTextController = TextEditingController();
  final key = GlobalKey();

  void webAuth() async {
    try {
      bool? res = await Navigator.of(key.currentContext!).push(
        MaterialPageRoute(
          builder: (context) {
            return CustomBrowser(
              url: '$urlAT/account/login',
              shouldOverrideUrlLoading: (action) {
                final url = action.request.url!;
                if (url.origin + url.path == '$urlAT/') {
                  Navigator.pop(context, true);
                }
                return NavigationActionPolicy.ALLOW;
              },
              userAgent:
                  'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Mobile Safari/537.36 EdgA/127.0.0.0 $userAgentAT',
            );
          },
        ),
      );

      if (res != true) throw 'Авторизация отменена';

      await service.login();

      if (key.currentContext != null) {
        overlaySnackMessage(key.currentContext!, 'Успешная авторизация');
      }
    } catch (e) {
      logger.e('[AuthorToday] Web auth error', error: e);

      if (key.currentContext != null) {
        overlaySnackMessage(key.currentContext!, e.toString());
      }
    }
  }

  @observable
  bool isTokenAuthActive = false;

  @observable
  bool isTokenAuthLoading = false;

  @action
  void startTokenAuth() => isTokenAuthActive = true;

  @action
  Future tokenAuth() async {
    isTokenAuthLoading = true;
    try {
      await service.loginByToken(tokenTextController.text);
    } catch (e) {
      logger.e('[AuthorToday] Token auth error', error: e);

      if (key.currentContext != null) {
        overlaySnackMessage(key.currentContext!, e.toString());
      }
    }
    isTokenAuthLoading = false;
  }

  void logout() => service.logout();
}
