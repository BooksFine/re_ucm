part of '../portal.dart';

/// Централизованное знание об auth-возможностях порталов.
/// Раньше хардкод `code != 'ficbook'` жил в presentation
/// (`portal_domain_extension`, `unauthorized_download_dialog`).
/// Держим в одном месте рядом с моделью; конкретные порталы
/// позже смогут переопределить через собственное поле.
extension PortalAuthSupport on Portal {
  bool get supportsAuth => code != 'ficbook';
}
