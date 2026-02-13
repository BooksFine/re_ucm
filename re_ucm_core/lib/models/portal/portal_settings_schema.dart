part of '../portal.dart';

sealed class PortalSettingItem<T extends PortalSettings> {
  const PortalSettingItem();
}

final class PortalSettingSectionTitle<T extends PortalSettings>
    extends PortalSettingItem<T> {
  const PortalSettingSectionTitle(this.title);

  final String title;
}

final class PortalSettingActionButton<T extends PortalSettings>
    extends PortalSettingItem<T> {
  const PortalSettingActionButton({
    required this.actionId,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final String actionId;
  final String title;
  final PortalSettingsActionHandler<T> onTap;
  final String? subtitle;
}

typedef PortalSettingsActionHandler<T extends PortalSettings> =
    Future<T> Function(T settings);

final class PortalSettingTextField<T extends PortalSettings>
    extends PortalSettingItem<T> {
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
  final PortalSettingsTextFieldHandler<T>? onChanged;
  final PortalSettingsTextFieldHandler<T>? onSubmit;
}

typedef PortalSettingsTextFieldHandler<T extends PortalSettings> =
    Future<T> Function(T settings, String value);
