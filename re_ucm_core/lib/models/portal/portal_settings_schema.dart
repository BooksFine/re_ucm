part of '../portal.dart';

sealed class PortalSettingItem {
  const PortalSettingItem();
}

final class PortalSettingStateSwitcher<T> extends PortalSettingItem {
  const PortalSettingStateSwitcher({
    required this.currentState,
    required this.states,
  });

  final T currentState;
  final Map<T, PortalSettingItem> states;
}

final class PortalSettingGroup extends PortalSettingItem {
  const PortalSettingGroup(this.children);

  final List<PortalSettingItem> children;
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

final class PortalSettingWebAuthButton extends PortalSettingItem {
  const PortalSettingWebAuthButton({
    required this.actionId,
    required this.title,
    required this.startUrl,
    required this.successUrl,
    required this.cookieName,
    required this.onCookieObtained,
    this.userAgent,
  });

  final String actionId;
  final String title;
  final String startUrl;
  final String successUrl;
  final String cookieName;
  final String? userAgent;
  final PortalSettingsWebAuthHandler onCookieObtained;
}

typedef PortalSettingsWebAuthHandler =
    Future<PortalSettings> Function(PortalSettings settings, String cookie);
