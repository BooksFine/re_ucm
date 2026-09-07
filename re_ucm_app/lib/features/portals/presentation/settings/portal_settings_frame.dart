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
  static const double _kFieldHPadding = AppSpacing.md;
  static const double _kFieldVPaddingCounter = AppSpacing.sm;
  static const double _kFieldVPaddingTile = 10;

  late PortalSettingsManager _manager;

  @override
  void initState() {
    super.initState();
    _initManager();
  }

  void _initManager() {
    _manager = PortalSettingsManager(
      session: widget.session,
      onNotify: (message, {kind = AppSnackKind.info}) {
        if (!mounted) return;
        AppSnack.show(context, message, kind: kind);
      },
    );
  }

  @override
  void didUpdateWidget(covariant PortalSettingsFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.session != widget.session) {
      _initManager();
    }
  }

  @override
  void dispose() {
    widget.session.resetTempFlags();
    super.dispose();
  }

  void onActionButtonTap(PortalSettingActionButton field) {
    _manager.onActionButtonTap(field);
  }

  void onNumberFieldChanged(PortalSettingNumberField field, int value) {
    _manager.onNumberFieldChanged(field, value);
  }

  void onWebAuthButtonTap(PortalSettingWebAuthButton field) async {
    await _manager.onWebAuthButtonTap(field);
    if (!mounted) return;
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
    return PortalSettingsTextField(
      key: ValueKey(field.actionId),
      title: field.title,
      initialValue: field.value,
      hint: field.hint ?? 'Введите значение',
      onChanged: field.onChanged != null
          ? (v) => field.onChanged!(widget.session.settings, v)
          : null,
      onSubmit: (v) => _manager.onTextFieldSubmit(field, v, null),
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
      isDestructive: field.isDestructive || field.actionId == 'logout',
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
