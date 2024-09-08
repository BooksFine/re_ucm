import 'package:flutter/material.dart';

final darkTheme = ThemeData(
  fontFamily: 'Roboto',
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: const Color(0xFFE88300),
    primary: const Color(0xFFE88300),
    onPrimary: Colors.white,
    onPrimaryContainer: Colors.white,
  ),
);

final lightTheme = ThemeData(
  fontFamily: 'Roboto',
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF91d1fd),
    primary: const Color(0xFF91d1fd),
  ),
);
