import 'package:flutter/painting.dart';

abstract final class AppRadii {
  /// 4.0 - micro progress indicators, tiny bars
  static const double xs = 4.0;

  /// 8.0 - chips, small tags, sub-element badges
  static const double sm = 8.0;

  /// 12.0 - icon containers, inner nested blocks
  static const double md = 12.0;

  /// 16.0 - list item tiles, text fields, embedded frames
  static const double lg = 16.0;

  /// 18.0 - primary card containers, settings cards, hero cards
  static const double card = 18.0;

  /// 20.0 - dialogs, modal bottom sheets
  static const double dialog = 20.0;

  /// 999.0 - pill-shaped buttons, status pills, stadium borders
  static const double full = 999.0;

  // Ready-to-use BorderRadius constants
  static const BorderRadius xsRadius = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smRadius = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgRadius = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(card));
  static const BorderRadius dialogRadius = BorderRadius.all(Radius.circular(dialog));
  static const BorderRadius fullRadius = BorderRadius.all(Radius.circular(full));
}

abstract final class AppSpacing {
  /// 4.0
  static const double xs = 4.0;

  /// 8.0
  static const double sm = 8.0;

  /// 12.0
  static const double md = 12.0;

  /// 16.0
  static const double lg = 16.0;

  /// 20.0
  static const double xl = 20.0;

  /// 24.0
  static const double xxl = 24.0;

  /// 96.0 — отступ снизу под плавающий навбар на мобильных устройствах.
  static const double bottomBarClearance = 96.0;
}

abstract final class AppBreakpoints {
  /// 600 — mobile/wide для модалов и навигации.
  static const double mobileNav = 600.0;

  /// 780 — master/detail для sources.
  static const double sourcesSplit = 780.0;

  /// 840 — split главной.
  static const double homeSplit = 840.0;

  /// 1024 — широкие карточки recent.
  static const double wideCards = 1024.0;
}

/// Единый источник alpha для `withValues(alpha: ...)`.
///
/// Значения зафиксированы по факту использования в дизайн-системе
/// (core/ui + common/widgets), замена — только внутри своей зоны,
/// пиксель в пиксель, без визуального дрейфа.
abstract final class AppOpacity {
  /// 0.38 — disabled-текст/иконки (Material guideline).
  static const double disabled = 0.38;

  /// 0.8 — сильные бордеры инпутов, приглушённые субтитры.
  static const double strong = 0.8;

  /// 0.7 — вторичные иконки (chevron), хинты текстовых полей.
  static const double emphasized = 0.7;

  /// 0.5 — бордеры карточек (CardTheme).
  static const double half = 0.5;

  /// 0.4 — разделители, бордеры меню.
  static const double muted = 0.4;

  /// 0.35 — бордеры поповеров.
  static const double soft = 0.35;

  /// 0.15 — заливки/разделители на tinted-поверхностях.
  static const double wash = 0.15;

  /// 0.22 — бордеры tinted-поверхностей (прогресс-карточки).
  static const double tintBorder = 0.22;

  /// 0.10 — фоновые tinted-заливки (прогресс-карточки).
  static const double tint = 0.1;

  /// 0.12 — мягкие тени поповеров.
  static const double shadow = 0.12;

  /// 0.85 — пиковый scrim градиента схлопнутого app bar'а.
  static const double scrimPeak = 0.85;
}

/// Единый источник толщин бордеров/разделителей.
abstract final class AppBorderWidth {
  /// 0.5 — hairline-разделители на tinted-поверхностях.
  static const double hairline = 0.5;

  /// 0.8 — тонкие бордеры поповеров и прогресс-карточек.
  static const double thin = 0.8;

  /// 1.0 — стандартные бордеры карточек и разделители.
  static const double regular = 1.0;

  /// 1.8 — акцентный бордер сфокусированного инпута.
  static const double thick = 1.8;
}

/// Единый источник длительностей анимаций дизайн-системы.
///
/// Значения зафиксированы по факту использования, замена — только
/// внутри своей зоны.
abstract final class AppDurations {
  /// 80ms — fade-out поповера при dismiss.
  static const Duration fadeOut = Duration(milliseconds: 80);

  /// 140ms — задержка снятия overlay поповера после dismiss.
  static const Duration exit = Duration(milliseconds: 140);

  /// 180ms — fade-in поповера при появлении.
  static const Duration fadeIn = Duration(milliseconds: 180);

  /// 250ms — AnimatedSize раскрытия прогресс-карточки.
  static const Duration expand = Duration(milliseconds: 250);
}
