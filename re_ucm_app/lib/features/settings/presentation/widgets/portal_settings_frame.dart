import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:re_ucm_core/models/portal.dart';

import '../../../../core/navigation/router_delegate.dart';
import '../../../../core/ui/constants.dart';
import '../../../../core/ui/settings.dart';
import '../../../portals/application/portal_session.cg.dart';

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
    return _textFieldsData[field.actionId] ??= (
      controller: TextEditingController(),
      isLoading: false,
    );
  }

  void onActionButtonTap(PortalSettingActionButton field) async {
    await updateSettings(await field.onTap(widget.session.settings));
  }

  void onWebAuthButtonTap(PortalSettingWebAuthButton field) async {
    final result = await Nav.pushWebAuth(field);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final cookie = result as String?;
    if (cookie == null || cookie.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Авторизация отменена')),
      );
      return;
    }
    try {
      await updateSettings(
        await field.onCookieObtained(widget.session.settings, cookie),
      );
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Вы успешно авторизовались')),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
  }

  Future<void> updateSettings(PortalSettings newSettings) async {
    final wasAuthorized = widget.session.isAuthorized;

    await widget.session.updateSettings(newSettings);

    if (wasAuthorized && !widget.session.isAuthorized) {
      final cookieManager = CookieManager.instance();
      cookieManager.deleteCookies(url: WebUri(widget.session.url));
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
    return switch (field) {
      PortalSettingGroup() => Column(
        children: [for (final child in field.children) renderField(child)],
      ),
      PortalSettingStateSwitcher() => AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: field.states.containsKey(field.currentState)
            ? KeyedSubtree(
                key: ValueKey(field.currentState),
                child: renderField(field.states[field.currentState]!),
              )
            : const SizedBox.shrink(),
      ),
      PortalSettingSectionTitle() => Padding(
        padding: const EdgeInsets.only(top: appPadding * 2),
        child: SettingsTitle(field.title),
      ),
      PortalSettingTextField() => SettingsTextField(
        hint: field.hint ?? 'Введите значение',
        controller: _getOrInitFieldData(field).controller,
        isLoading: _getOrInitFieldData(field).isLoading,
        onSubmit: (v) => onTextFieldSubmit(field, v),
      ),
      PortalSettingActionButton() => SettingsButton(
        title: field.title,
        subtitle: field.subtitle,
        onTap: () => onActionButtonTap(field),
      ),
      PortalSettingWebAuthButton() => SettingsButton(
        title: field.title,
        leading: const Icon(Icons.language),
        onTap: () => onWebAuthButtonTap(field),
      ),
    };
  }
}
