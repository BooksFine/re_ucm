part of '../portal.dart';

sealed class PortalSettingItem {
  const PortalSettingItem();
}

final class PortalSettingSectionTitle extends PortalSettingItem {
  const PortalSettingSectionTitle(this.title);

  final String title;
}

final class PortalSettingActionButton extends PortalSettingItem {
  const PortalSettingActionButton({
    required this.actionId,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final String actionId;
  final String title;
  final PortalSettingsActionHandler onTap;
  final String? subtitle;
}

typedef PortalSettingsActionHandler =
    Future<PortalSettings> Function(PortalSettings settings);

final class PortalSettingTextField extends PortalSettingItem {
  const PortalSettingTextField({
    required this.actionId,
    required this.title,
    this.hint,
    this.onChanged,
    this.onSubmit,
  });

  final String actionId;
  final String title;
  final String? hint;
  final PortalSettingsTextFieldHandler? onChanged;
  final PortalSettingsTextFieldHandler? onSubmit;
}

typedef PortalSettingsTextFieldHandler =
    Future<PortalSettings> Function(PortalSettings settings, String value);
