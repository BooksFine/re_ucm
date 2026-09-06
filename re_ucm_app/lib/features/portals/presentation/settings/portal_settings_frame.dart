import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/models/portal.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';
import 'package:webview_all/webview_all.dart';

import '../../../../core/navigation/router_delegate.dart';
import '../../../../core/ui/tokens.dart';
import '../../../../core/ui/widgets/app_counter_row.dart';
import '../../../../core/ui/widgets/app_tile.dart';
import '../../../common/widgets/overlay_snack.dart';
import 'widgets/portal_animated_switcher.dart';
import 'widgets/portal_settings_text_field.dart';


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
    // Временные флаги сессии живут ровно пока открыт фрейм настроек —
    // сброс здесь, а не в lifecycle сессии, осознанно.
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

  /// Вынесено из switch-expression: `_getOrInitFieldData` вызывается
  /// один раз за build (раньше — дважды, с побочным эффектом в геттере).
  Widget _textFieldWidget(PortalSettingTextField field) {
    final fieldData = _getOrInitFieldData(field);
    return PortalSettingsTextField(
      title: field.title,
      hint: field.hint ?? 'Введите значение',
      controller: fieldData.controller,
      isLoading: fieldData.isLoading,
      onChanged: field.onChanged != null
          ? (v) => field.onChanged!(widget.session.settings, v)
          : null,
      onSubmit: (v) => onTextFieldSubmit(field, v),
    );
  }

  Widget renderField(PortalSettingItem field) {
    return switch (field) {      PortalSettingGroup() => Column(
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
      PortalSettingSectionTitle() => const SizedBox.shrink(),
      PortalSettingTextField() => _textFieldWidget(field),
      PortalSettingNumberField() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: AppCounterRow(
          title: field.title,
          subtitle: field.subtitle,
          value: field.value,
          min: field.min,
          max: field.max,
          onChanged: (v) => onNumberFieldChanged(field, v),
        ),
      ),
      PortalSettingActionButton() => AppTile(
        title: field.title,
        subtitle: field.subtitle,
        isDestructive: field.actionId == 'logout',
        onTap: () => onActionButtonTap(field),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        borderRadius: AppRadii.lg,
      ),
      PortalSettingWebAuthButton() => AppTile(
        title: field.title,
        onTap: () => onWebAuthButtonTap(field),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        borderRadius: AppRadii.lg,
      ),
    };
  }
}

