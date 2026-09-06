part of '../portal.dart';

/// Централизованное знание об auth-возможностях порталов.
/// Раньше хардкод `code != 'ficbook'` жил в presentation
/// (`portal_domain_extension`, `unauthorized_download_dialog`).
/// Держим в одном месте рядом с моделью; конкретные порталы
/// позже смогут переопределить через собственное поле.
/// TODO: поле `supportsAuth` на [Portal] требует правок реализаций
/// в portals/ (вне владения) — тогда этот хардкод кода уедет в Ficbook.
extension PortalAuthSupport on Portal {
  bool get supportsAuth => code != 'ficbook';
}
