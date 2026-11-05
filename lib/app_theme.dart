import 'package:flutter/material.dart';

class OpenCredTheme {
  static const ink = Color(0xFF30231D);
  static const canvas = Color(0xFFF5EFE6);
  static const blue = Color(0xFF895A3C);
  static const green = Color(0xFF55735B);
  static const amber = Color(0xFFAE7637);
  static const red = Color(0xFFA34F43);
  static const sand = Color(0xFFE9DCCB);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: blue, brightness: Brightness.light);
    return ThemeData(
      colorScheme: scheme.copyWith(primary: blue, surface: Colors.white, onSurface: ink),
      scaffoldBackgroundColor: canvas,
      useMaterial3: true,
      fontFamily: 'Avenir',
      appBarTheme: const AppBarTheme(backgroundColor: canvas, foregroundColor: ink, elevation: 0),
      cardTheme: CardThemeData(color: Colors.white, elevation: 0, margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(22)))),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: blue, width: 1.5),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: sand,
        elevation: 3,
      ),
    );
  }
}
