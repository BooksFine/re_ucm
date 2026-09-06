import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/models/portal.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';
import 'package:webview_all/webview_all.dart';

import '../../../../core/navigation/router_delegate.dart';
import '../../../../core/ui/constants.dart';
import '../../../common/widgets/overlay_snack.dart';
import 'widgets/portal_animated_switcher.dart';
import 'widgets/portal_settings_button.dart';
import 'widgets/portal_settings_number_field.dart';
import 'widgets/portal_settings_text_field.dart';
import 'widgets/portal_settings_title.dart';

class PortalSettingsFrame extends StatefulWidget {
  const PortalSettingsFrame({super.key, required this.session});

  final PortalSession session;

  @override
  State<PortalSettingsFrame> createState() => _PortalSettingsFrameState();
}

class _PortalSettingsFrameState extends State<PortalSettingsFrame> {
  final Map<String, ({TextEditingController controller, bool isLoading})>
  _textFieldsData = {};

  @override
  void dispose() {
    widget.session.resetTempFlags();
    for (final data in _textFieldsData.values) {
      data.controller.dispose();
    }
    super.dispose();
  }

  void onTextFieldSubmit(PortalSettingTextField field, String value) async {
    updateFieldData(field, isLoading: true);

    await updateSettings(await field.onSubmit!(widget.session.settings, value));

    updateFieldData(field, isLoading: false);
  }

  void updateFieldData(PortalSettingTextField field, {bool? isLoading}) {
    final data = _getOrInitFieldData(field);

    _textFieldsData[field.actionId] = (
      controller: data.controller,
      isLoading: isLoading ?? data.isLoading,
    );

    if (mounted) setState(() {});
  }

  ({TextEditingController controller, bool isLoading}) _getOrInitFieldData(
    PortalSettingTextField field,
  ) {
    final existing = _textFieldsData[field.actionId];
    if (existing != null) {
      return existing;
    }
    final controller = TextEditingController(text: field.value ?? '');
    return _textFieldsData[field.actionId] = (
      controller: controller,
      isLoading: false,
    );
  }

  void onActionButtonTap(PortalSettingActionButton field) async {
    await updateSettings(await field.onTap(widget.session.settings));
  }

  void onNumberFieldChanged(PortalSettingNumberField field, int value) async {
    await updateSettings(await field.onChanged(widget.session.settings, value));
  }

  void onWebAuthButtonTap(PortalSettingWebAuthButton field) async {
    final result = await Nav.pushWebAuth(field);
    final cookie = result as String?;
    if (cookie == null || cookie.isEmpty) {
      if (!mounted) return;
      overlaySnackMessage(context, 'Авторизация отменена');
      return;
    }
    try {
      await updateSettings(
        await field.onCookieObtained(widget.session.settings, cookie),
      );
      if (!mounted) return;
      overlaySnackMessage(context, 'Вы успешно авторизовались');
    } catch (e) {
      if (!mounted) return;
      overlaySnackMessage(context, 'Ошибка: $e');
    }
  }

  Future<void> updateSettings(PortalSettings newSettings) async {
    final wasAuthorized = widget.session.isAuthorized;

    await widget.session.updateSettings(newSettings);

    if (wasAuthorized && !widget.session.isAuthorized) {
      await WebViewCookieManager().clearCookies();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Column(
        children: [
          for (final field in widget.session.schema) renderField(field),
        ],
      ),
    );
  }

  Widget renderField(PortalSettingItem field) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return switch (field) {
      PortalSettingGroup() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [for (final child in field.children) renderField(child)],
      ),
      PortalSettingStateSwitcher() => PortalAnimatedSwitcher(
        child: field.states.containsKey(field.currentState)
            ? KeyedSubtree(
                key: ValueKey(field.currentState),
                child: renderField(field.states[field.currentState]!),
              )
            : const SizedBox.shrink(),
      ),
      PortalSettingSectionTitle() =>
        (field.title.toLowerCase() == widget.session.name.toLowerCase() ||
                field.title.toLowerCase() == widget.session.code.toLowerCase())
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.only(left: 12, top: 12, bottom: 4),
                child: Text(
                  field.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
              ),
      PortalSettingTextField() => PortalSettingsTextField(
        title: field.title,
        hint: field.hint ?? 'Введите значение',
        controller: _getOrInitFieldData(field).controller,
        isLoading: _getOrInitFieldData(field).isLoading,
        onChanged: field.onChanged != null
            ? (v) => field.onChanged!(widget.session.settings, v)
            : null,
        onSubmit: (v) => onTextFieldSubmit(field, v),
      ),
      PortalSettingNumberField() => PortalSettingsNumberField(
        title: field.title,
        subtitle: field.subtitle,
        value: field.value,
        min: field.min,
        max: field.max,
        onChanged: (v) => onNumberFieldChanged(field, v),
      ),
      PortalSettingActionButton() => PortalSettingsButton(
        title: field.title,
        subtitle: field.subtitle,
        isDestructive: field.actionId == 'logout',
        leading: field.actionId == 'logout'
            ? Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.errorContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  size: 20,
                  color: cs.error,
                ),
              )
            : (field.actionId.contains('token') ||
                    field.actionId.contains('sid'))
                ? Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.key_rounded,
                      size: 20,
                      color: cs.primary,
                    ),
                  )
                : null,
        trailing: field.actionId == 'logout'
            ? Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: cs.error.withValues(alpha: 0.7),
              )
            : null,
        onTap: () => onActionButtonTap(field),
      ),
      PortalSettingWebAuthButton() => PortalSettingsButton(
        title: field.title,
        subtitle: 'Вход через встроенный браузер сервиса',
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.open_in_browser_rounded,
            size: 20,
            color: cs.onPrimaryContainer,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_rounded,
          size: 20,
          color: cs.onSurfaceVariant,
        ),
        onTap: () => onWebAuthButtonTap(field),
      ),
    };
  }
}

