import 'package:material_ui/material_ui.dart';

/// Кастомные цвета дизайн-системы.
///
/// Источник бордеров — [ColorScheme.outlineVariant] (+ CardTheme в
/// theme.dart как база); хранить дубли в расширении запрещено, поэтому
/// исторического `cardBorder` здесь больше нет.
///
/// Исторический дубль успеха удалён: все чтения переведены
/// на [success] (`portal_card`, `portal_badges`).
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.success,
    required this.onSuccess,
    required this.statusOffline,
  });

  final Color success;
  final Color onSuccess;
  final Color statusOffline;

  static const dark = AppColorsExtension(
    success: Color(0xFF4CAF50),
    onSuccess: Colors.white,
    statusOffline: Color(0x998C9199),
  );

  static const light = AppColorsExtension(
    success: Color(0xFF2E7D32),
    onSuccess: Colors.white,
    statusOffline: Color(0x9972777F),
  );

  @override
  AppColorsExtension copyWith({
    Color? success,
    Color? onSuccess,
    Color? statusOffline,
  }) {
    return AppColorsExtension(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
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
