import 'package:flutter/material.dart';
import 'package:re_ucm_core/models/portal.dart';
import 'package:re_ucm_core/models/portal/portal_settings.dart';

import '../../../../core/ui/constants.dart';
import '../../../../core/ui/settings.dart';
import '../../application/settings_service.cg.dart';

class PortalSettingsFrame extends StatefulWidget {
  const PortalSettingsFrame({
    super.key,
    required this.portal,
    required this.service,
  });

  final Portal portal;
  final SettingsService service;

  @override
  State<PortalSettingsFrame> createState() => _PortalSettingsFrameState();
}

class _PortalSettingsFrameState extends State<PortalSettingsFrame> {
  late PortalSettings settings;
  late List<PortalSettingItem> scheme;

  final Map<String, ({TextEditingController controller, bool isLoading})>
  _textFieldsData = {};

  @override
  void initState() {
    settings = widget.service.getPortalSettings(widget.portal);
    scheme = widget.portal.service.buildSettingsSchema(settings);

    for (final item in scheme) {
      if (item is PortalSettingTextField) {
        updateFieldData(item);
      }
    }

    super.initState();
  }

  void onTextFieldSubmit(PortalSettingTextField field, String value) async {
    updateFieldData(field, isLoading: true);

    updateSettings(await field.onSubmit!(settings, value));

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
    updateSettings(await field.onTap(settings));
  }

  void updateSettings(PortalSettings newSettings) {
    settings = newSettings;
    widget.service.replacePortalSettings(widget.portal, settings);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final field in scheme)
          switch (field) {
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
          },
      ],
    );
  }
}
