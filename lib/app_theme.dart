import 'package:flutter/material.dart';

class OpenCredTheme {
  static const ink = Color(0xFF30231D);
  static const canvas = Color(0xFFF5EFE6);
  static const blue = Color(0xFF895A3C);
  static const green = Color(0xFF55735B);
  static const amber = Color(0xFFAE7637);
  static const red = Color(0xFFA34F43);
  static const sand = Color(0xFFE9DCCB);
  static const glass = Color(0xD9FFFFFF);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: blue, brightness: Brightness.light);
    return ThemeData(
      colorScheme: scheme.copyWith(primary: blue, surface: Colors.white, onSurface: ink),
      scaffoldBackgroundColor: canvas,
      useMaterial3: true,
      fontFamily: 'SF Pro Display',
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 16, height: 1.35, letterSpacing: -.1),
        bodyMedium: TextStyle(fontSize: 14, height: 1.35, letterSpacing: -.05),
        titleLarge: TextStyle(fontSize: 22, height: 1.15, letterSpacing: -.4, fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(fontSize: 30, height: 1.08, letterSpacing: -.8, fontWeight: FontWeight.w800),
      ),
      appBarTheme: const AppBarTheme(backgroundColor: canvas, foregroundColor: ink, elevation: 0),
      cardTheme: CardThemeData(
        color: glass,
        surfaceTintColor: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: ContinuousRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(28))),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: const ContinuousRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(22))),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: blue, width: 1.5),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: glass,
        indicatorColor: sand,
        elevation: 0,
        labelTextStyle: WidgetStatePropertyAll(TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
