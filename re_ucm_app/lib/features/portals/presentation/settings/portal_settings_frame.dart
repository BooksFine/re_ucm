import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/models/portal.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../../core/ui/tokens.dart';
import '../../../../core/ui/widgets/app_counter_row.dart';
import '../../../../core/ui/widgets/app_section_header.dart';
import '../../../../core/ui/widgets/app_tile.dart';
import '../../../common/widgets/snack.dart';
import 'portal_settings_manager.dart';
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

  static const double _kFieldHPadding = 12;
  static const double _kFieldVPaddingCounter = 8;
  static const double _kFieldVPaddingTile = 10;

  late final PortalSettingsManager _manager = PortalSettingsManager(
    session: widget.session,
    onNotify: (message, {kind = AppSnackKind.info}) {
      if (!mounted) return;
      AppSnack.show(context, message, kind: kind);
    },
  );

  @override
  void didUpdateWidget(covariant PortalSettingsFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.session, widget.session)) {
      _pruneStaleFieldControllers();
    }
  }

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
    try {
      await _manager.onTextFieldSubmit(field, value, null);
    } finally {
      if (mounted) updateFieldData(field, isLoading: false);
    }
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

  void onActionButtonTap(PortalSettingActionButton field) {
    _manager.onActionButtonTap(field);
  }

  void onNumberFieldChanged(PortalSettingNumberField field, int value) {
    _manager.onNumberFieldChanged(field, value);
  }

  void onWebAuthButtonTap(PortalSettingWebAuthButton field) async {
    await _manager.onWebAuthButtonTap(field, mounted);
  }

  void _pruneStaleFieldControllers() {
    final alive = <String>{};
    for (final field in widget.session.schema) {
      _collectTextFieldIds(field, alive);
    }
    final stale = _textFieldsData.keys.where((k) => !alive.contains(k)).toList();
    for (final key in stale) {
      _textFieldsData.remove(key)?.controller.dispose();
    }
    if (stale.isNotEmpty && mounted) setState(() {});
  }

  void _collectTextFieldIds(PortalSettingItem field, Set<String> out) {
    switch (field) {
      case PortalSettingTextField():
        out.add(field.actionId);
      case PortalSettingGroup():
        for (final child in field.children) {
          _collectTextFieldIds(child, out);
        }
      case PortalSettingStateSwitcher():
        for (final child in field.states.values) {
          _collectTextFieldIds(child, out);
        }
      case _:
        break;
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
      PortalSettingSectionTitle() => AppSectionHeader(field.title),
      PortalSettingTextField() => _textFieldWidget(field),
      PortalSettingNumberField() => _numberFieldWidget(field),
      PortalSettingActionButton() => _actionButtonWidget(field),
      PortalSettingWebAuthButton() => _webAuthButtonWidget(field),
    };
  }

  Widget _numberFieldWidget(PortalSettingNumberField field) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _kFieldHPadding,
        vertical: _kFieldVPaddingCounter,
      ),
      child: AppCounterRow(
        title: field.title,
        subtitle: field.subtitle,
        value: field.value,
        min: field.min,
        max: field.max,
        onChanged: (v) => onNumberFieldChanged(field, v),
      ),
    );
  }

  Widget _actionButtonWidget(PortalSettingActionButton field) {
    return AppTile(
      title: field.title,
      subtitle: field.subtitle,
      isDestructive: field.actionId == 'logout',
      onTap: () => onActionButtonTap(field),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: _kFieldHPadding,
        vertical: _kFieldVPaddingTile,
      ),
      borderRadiusGeometry: AppRadii.lgRadius,
    );
  }

  Widget _webAuthButtonWidget(PortalSettingWebAuthButton field) {
    return AppTile(
      title: field.title,
      onTap: () => onWebAuthButtonTap(field),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: _kFieldHPadding,
        vertical: _kFieldVPaddingTile,
      ),
      borderRadiusGeometry: AppRadii.lgRadius,
    );
  }
}
