import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';

import 'app_colors_extension.dart';
import 'tokens.dart';

final _darkColorScheme = M3EColorScheme.dark(
  seedColor: const Color(0xFFE88300),
  variant: M3EColorVariant.vibrant,
).copyWith(
  primary: const Color(0xFFE88300),
  onPrimary: Colors.white,
  onPrimaryContainer: Colors.white,
  scrim: Colors.transparent,
);

final _lightColorScheme = M3EColorScheme.light(
  seedColor: const Color(0xFF91d1fd),
  variant: M3EColorVariant.vibrant,
).copyWith(
  primary: const Color(0xFF91d1fd),
  onPrimary: const Color(0xFF00344f),
  onPrimaryContainer: const Color(0xFF001F30),
  scrim: Colors.transparent,
);

ThemeData _buildTheme(ColorScheme cs, AppColorsExtension appColors) {
  final titleStyle = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: cs.onSurface,
  );

  return ThemeData(
    fontFamily: 'Roboto',
    visualDensity: VisualDensity.standard,
    colorScheme: cs,
    extensions: [appColors],
    appBarTheme: AppBarTheme(
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      titleTextStyle: titleStyle,
    ),
    textTheme: TextTheme(
      titleLarge: titleStyle,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: cs.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: BorderSide(
          color: cs.outlineVariant.withValues(alpha: 0.5),
          width: 1.0,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: cs.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        borderSide: BorderSide(
          color: cs.outlineVariant.withValues(alpha: 0.8),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        borderSide: BorderSide(
          color: cs.outlineVariant.withValues(alpha: 0.8),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        borderSide: BorderSide(
          color: cs.onSurfaceVariant,
          width: 1.8,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    dividerTheme: DividerThemeData(
      space: 1,
      thickness: 1,
      color: cs.outlineVariant.withValues(alpha: 0.4),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      elevation: 6,
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.dialog),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      elevation: 3,
      color: cs.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: BorderSide(
          color: cs.outlineVariant.withValues(alpha: 0.4),
          width: 0.8,
        ),
      ),
      menuPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
    ),
    menuTheme: MenuThemeData(
      style: MenuStyle(
        elevation: const WidgetStatePropertyAll<double>(3),
        backgroundColor: WidgetStatePropertyAll<Color>(cs.surfaceContainer),
        surfaceTintColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.card),
            side: BorderSide(
              color: cs.outlineVariant.withValues(alpha: 0.4),
              width: 0.8,
            ),
          ),
        ),
        padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        ),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: cs.surfaceContainerLowest,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadii.dialog),
        ),
      ),
    ),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        for (var platform in TargetPlatform.values)
          platform: const FadeForwardsPageTransitionsBuilder(),
      },
    ),
  );
}

final darkTheme = _buildTheme(_darkColorScheme, AppColorsExtension.dark);
final lightTheme = _buildTheme(_lightColorScheme, AppColorsExtension.light);
