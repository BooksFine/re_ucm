import 'package:re_ucm_core/re_ucm_core.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';
import 'package:webview_all/webview_all.dart';

import '../../../../core/navigation/nav.dart';
import '../../../common/widgets/snack.dart';

class PortalSettingsManager {
  PortalSettingsManager({required this.session, required this.onNotify});

  final PortalSession session;
  final void Function(String message, {AppSnackKind kind}) onNotify;

  Future<bool> updateSettings(PortalSettings newSettings) async {
    try {
      final wasAuthorized = session.isAuthorized;

      await session.updateSettings(newSettings);

      if (wasAuthorized && !session.isAuthorized) {
        try {
          await WebViewCookieManager().clearCookies();
        } catch (e) {
          onNotify('Ошибка очистки cookies: $e', kind: AppSnackKind.error);
        }
      }
      return true;
    } catch (e) {
      onNotify('Ошибка сохранения: $e', kind: AppSnackKind.error);
      return false;
    }
  }

  Future<bool> safeUpdate(Future<PortalSettings> Function() action) async {
    try {
      await updateSettings(await action());
      return true;
    } catch (e) {
      onNotify('Ошибка: $e', kind: AppSnackKind.error);
      return false;
    }
  }

  Future<void> onTextFieldSubmit(
    PortalSettingTextField field,
    String value,
    Future<PortalSettings> Function(PortalSettings, String)? onSubmit,
  ) async {
    final onSubmitCallback = field.onSubmit ?? onSubmit;
    if (onSubmitCallback == null) return;
    await updateSettings(await onSubmitCallback(session.settings, value));
  }

  void onNumberFieldChanged(PortalSettingNumberField field, int value) {
    safeUpdate(() => field.onChanged(session.settings, value));
  }

  void onActionButtonTap(PortalSettingActionButton field) {
    safeUpdate(() => field.onTap(session.settings));
  }

  Future<void> onWebAuthButtonTap(
    PortalSettingWebAuthButton field,
    bool mounted,
  ) async {
    final result = await Nav.pushWebAuth(field);
    final cookie = result as String?;
    if (cookie == null || cookie.isEmpty) {
      if (!mounted) return;
      onNotify('Авторизация отменена', kind: AppSnackKind.info);
      return;
    }
    final success = await safeUpdate(
      () => field.onCookieObtained(session.settings, cookie),
    );
    if (!mounted || !success) return;
    onNotify(
      'Вы успешно авторизовались',
      kind: AppSnackKind.success,
    );
  }
}
