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
