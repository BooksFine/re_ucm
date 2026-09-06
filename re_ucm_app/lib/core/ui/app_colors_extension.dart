import 'package:material_ui/material_ui.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.success,
    required this.onSuccess,
    required this.cardBorder,
    required this.subtleBorder,
    required this.statusOnline,
    required this.statusOffline,
  });

  final Color success;
  final Color onSuccess;
  final Color cardBorder;
  final Color subtleBorder;
  final Color statusOnline;
  final Color statusOffline;

  static const dark = AppColorsExtension(
    success: Color(0xFF4CAF50),
    onSuccess: Colors.white,
    cardBorder: Color(0x808C9199),
    subtleBorder: Color(0x4D8C9199),
    statusOnline: Color(0xFF4CAF50),
    statusOffline: Color(0x998C9199),
  );

  static const light = AppColorsExtension(
    success: Color(0xFF2E7D32),
    onSuccess: Colors.white,
    cardBorder: Color(0x8072777F),
    subtleBorder: Color(0x4D72777F),
    statusOnline: Color(0xFF2E7D32),
    statusOffline: Color(0x9972777F),
  );

  @override
  AppColorsExtension copyWith({
    Color? success,
    Color? onSuccess,
    Color? cardBorder,
    Color? subtleBorder,
    Color? statusOnline,
    Color? statusOffline,
  }) {
    return AppColorsExtension(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      cardBorder: cardBorder ?? this.cardBorder,
      subtleBorder: subtleBorder ?? this.subtleBorder,
      statusOnline: statusOnline ?? this.statusOnline,
      statusOffline: statusOffline ?? this.statusOffline,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) {
      return this;
    }
    return AppColorsExtension(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      subtleBorder: Color.lerp(subtleBorder, other.subtleBorder, t)!,
      statusOnline: Color.lerp(statusOnline, other.statusOnline, t)!,
      statusOffline: Color.lerp(statusOffline, other.statusOffline, t)!,
    );
  }
}

extension AppColorsBuildContext on BuildContext {
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? AppColorsExtension.dark
          : AppColorsExtension.light);
}
