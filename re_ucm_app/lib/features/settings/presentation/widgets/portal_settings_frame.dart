import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
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
  late List<PortalSettingItem> scheme;

  final Map<String, ({TextEditingController controller, bool isLoading})>
  _textFieldsData = {};

  @override
  void initState() {
    scheme = widget.session.service.buildSettingsSchema(
      widget.session.settings,
    );

    for (final item in scheme) {
      if (item is PortalSettingTextField) {
        updateFieldData(item);
      }
    }

    super.initState();
  }

  void onTextFieldSubmit(PortalSettingTextField field, String value) async {
    updateFieldData(field, isLoading: true);

    updateSettings(await field.onSubmit!(widget.session.settings, value));

    updateFieldData(field, isLoading: false);
  }

  void updateFieldData(PortalSettingTextField field, {bool? isLoading}) {
    final data =
        _textFieldsData[field.actionId] ??
        (controller: TextEditingController(), isLoading: false);

    _textFieldsData[field.actionId] = (
      controller: data.controller,
      isLoading: isLoading ?? data.isLoading,
    );

    setState(() {});
  }

  void onActionButtonTap(PortalSettingActionButton field) async {
    updateSettings(await field.onTap(widget.session.settings));
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
      updateSettings(
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

  void updateSettings(PortalSettings newSettings) async {
    final wasAuthorized = widget.session.isAuthorized;

    await widget.session.updateSettings(newSettings);

    scheme = widget.session.service.buildSettingsSchema(
      widget.session.settings,
    );

    // Init text field data for any new fields in the updated scheme
    for (final item in scheme) {
      if (item is PortalSettingTextField &&
          !_textFieldsData.containsKey(item.actionId)) {
        _textFieldsData[item.actionId] = (
          controller: TextEditingController(),
          isLoading: false,
        );
      }
    }

    if (wasAuthorized && !widget.session.isAuthorized) {
      final cookieManager = CookieManager.instance();
      await cookieManager.deleteCookies(url: WebUri(widget.session.url));
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [for (final field in scheme) renderField(field)]);
  }

  Widget renderField(PortalSettingItem field) {
    return switch (field) {
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
        controller: _textFieldsData[field.actionId]!.controller,
        isLoading: _textFieldsData[field.actionId]!.isLoading,
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
