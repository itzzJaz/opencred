import 'package:flutter/material.dart';

/// Spacing scale on a strict 4px grid.
abstract final class Spacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Square corners from the website's editorial card and button system.
abstract final class Radii {
  static const double card = 0;
  static const double field = 0;
  static const double row = 0;
  static const double capsule = 0;
}

abstract final class Layout {
  static const double pageGutter = 20;
  static const double navItemHeight = 54;
  static const double pageBottomInset = 96;
}

/// TrustScore's site palette: near-black, off-white, and signal red.
@immutable
class Palette {
  const Palette({
    required this.brightness,
    required this.canvas,
    required this.surface,
    required this.raised,
    required this.hairline,
    required this.ink,
    required this.onInk,
    required this.secondary,
    required this.muted,
    required this.accent,
    required this.onAccent,
    required this.accentTint,
    required this.positive,
    required this.warning,
    required this.negative,
    required this.hero,
    required this.onHero,
  });

  final Brightness brightness;
  final Color canvas;
  final Color surface;
  final Color raised;

  /// Clean 1px hairlines separating geometric flat surfaces.
  final Color hairline;
  final Color ink;
  final Color onInk;
  final Color secondary;
  final Color muted;

  /// Signal red used across the website's chips, rules and highlights.
  final Color accent;
  final Color onAccent;
  final Color accentTint;
  final Color positive;
  final Color warning;
  final Color negative;

  /// Full-bleed matte ink band.
  final Color hero;
  final Color onHero;

  bool get isDark => brightness == Brightness.dark;

  static Palette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  static const light = Palette(
    brightness: Brightness.light,
    canvas: Color(0xFFF4F3EF),
    surface: Color(0xFFECEBE7),
    raised: Color(0xFFDEDDDA),
    hairline: Color(0x24141416),
    ink: Color(0xFF0A0A0B),
    onInk: Color(0xFFF4F3EF),
    secondary: Color(0xFF515155),
    muted: Color(0xFF77777C),
    accent: Color(0xFFE10600),
    onAccent: Color(0xFFFFFFFF),
    accentTint: Color(0x26E10600),
    positive: Color(0xFF176B4A),
    warning: Color(0xFF526A88),
    negative: Color(0xFFE10600),
    hero: Color(0xFF0A0A0B),
    onHero: Color(0xFFF4F3EF),
  );

  static const dark = Palette(
    brightness: Brightness.dark,
    canvas: Color(0xFF0A0A0B),
    surface: Color(0xFF141416),
    raised: Color(0xFF1D1D20),
    hairline: Color(0x29FFFFFF),
    ink: Color(0xFFF4F3EF),
    onInk: Color(0xFF0A0A0B),
    secondary: Color(0xFFA2A2A6),
    muted: Color(0xFF77777C),
    accent: Color(0xFFE10600),
    onAccent: Color(0xFFFFFFFF),
    accentTint: Color(0x33E10600),
    positive: Color(0xFF62BD91),
    warning: Color(0xFF9BA6B7),
    negative: Color(0xFFE10600),
    hero: Color(0xFF0A0A0B),
    onHero: Color(0xFFF4F3EF),
  );
}

class OpenCredTheme {
  static ThemeData light() => _build(Palette.light);
  static ThemeData dark() => _build(Palette.dark);

  static TextStyle _style(
    Palette p,
    double size,
    double height,
    FontWeight weight, [
    double letterSpacing = 0,
  ]) =>
      TextStyle(
        fontFamily: 'Barlow',
        color: p.ink,
        fontSize: size,
        height: height,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle _displayStyle(
    Palette p,
    double size,
    double height,
    double letterSpacing,
  ) =>
      TextStyle(
        fontFamily: 'BarlowCondensed',
        fontStyle: FontStyle.italic,
        color: p.ink,
        fontSize: size,
        height: height,
        fontWeight: FontWeight.w900,
        letterSpacing: letterSpacing,
      );

  static OutlineInputBorder _fieldBorder(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.field),
        borderSide: BorderSide(color: color, width: width),
      );

  static ThemeData _build(Palette p) {
    final scheme =
        ColorScheme.fromSeed(seedColor: p.accent, brightness: p.brightness)
            .copyWith(
      primary: p.accent,
      onPrimary: p.onAccent,
      secondary: p.accent,
      onSecondary: p.onAccent,
      tertiary: p.positive,
      surface: p.surface,
      onSurface: p.ink,
      surfaceContainerHighest: p.raised,
      onSurfaceVariant: p.secondary,
      outline: p.muted,
      outlineVariant: p.hairline,
      error: p.negative,
      onError: Colors.white,
    );

    final text = TextTheme(
      displayLarge: _displayStyle(p, 64, .92, -.6),
      displayMedium: _displayStyle(p, 48, .94, -.5),
      displaySmall: _displayStyle(p, 38, .96, -.4),
      headlineLarge: _displayStyle(p, 38, .95, -.5),
      headlineMedium: _displayStyle(p, 32, .98, -.25),
      headlineSmall: _displayStyle(p, 26, 1.02, 0),
      titleLarge: _displayStyle(p, 21, 1.08, .15),
      titleMedium: _style(p, 15, 1.25, FontWeight.w600),
      bodyLarge: _style(p, 15, 1.45, FontWeight.w400),
      bodyMedium: _style(p, 13.5, 1.45, FontWeight.w400),
      bodySmall: _style(p, 12, 1.4, FontWeight.w400),
      labelLarge: _style(p, 14, 1.2, FontWeight.w700, 0.4)
          .copyWith(fontFamily: 'BarlowCondensed'),
      labelMedium: _style(p, 12, 1.2, FontWeight.w600, 0.4)
          .copyWith(fontFamily: 'BarlowCondensed'),
      labelSmall: _style(p, 10.5, 1.3, FontWeight.w600, 0.6)
          .copyWith(fontFamily: 'BarlowCondensed'),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.canvas,
      textTheme: text.apply(bodyColor: p.ink, displayColor: p.ink),
      iconTheme: IconThemeData(color: p.secondary, size: 20),
      cardTheme: CardThemeData(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: p.hairline, width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: p.hairline,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.canvas,
        foregroundColor: p.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.accent,
          foregroundColor: p.onAccent,
          disabledBackgroundColor: p.raised,
          disabledForegroundColor: p.muted,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          elevation: 0,
          textStyle: _style(p, 17, 1.05, FontWeight.w500, .7)
              .copyWith(fontFamily: 'BarlowCondensed'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: p.accent),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.ink,
          side: BorderSide(color: p.hairline),
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          elevation: 0,
          textStyle: _style(p, 17, 1.05, FontWeight.w500, .7)
              .copyWith(fontFamily: 'BarlowCondensed'),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.ink,
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          textStyle: _style(p, 13.5, 1.2, FontWeight.w600),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: 14,
        ),
        hintStyle: TextStyle(color: p.muted, fontSize: 14),
        labelStyle: TextStyle(color: p.secondary, fontSize: 14),
        floatingLabelStyle: TextStyle(
          color: p.ink,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        border: _fieldBorder(p.hairline),
        enabledBorder: _fieldBorder(p.hairline),
        focusedBorder: _fieldBorder(p.accent, width: 1.5),
        errorBorder: _fieldBorder(p.negative),
        focusedErrorBorder: _fieldBorder(p.negative, width: 1.5),
        errorStyle: TextStyle(color: p.negative, fontSize: 12),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.secondary,
        textColor: p.ink,
        contentPadding: EdgeInsets.zero,
        minVerticalPadding: Spacing.sm,
        titleTextStyle: _style(p, 15, 1.3, FontWeight.w600),
        subtitleTextStyle: TextStyle(
          color: p.secondary,
          fontSize: 12,
          height: 1.35,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.accent,
        linearTrackColor: p.raised,
        circularTrackColor: p.raised,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.accent,
        selectionColor: p.accent.withValues(alpha: 0.28),
        selectionHandleColor: p.accent,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.surface,
        contentTextStyle: TextStyle(color: p.ink, fontSize: 13.5),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      splashColor: p.ink.withValues(alpha: 0.04),
      highlightColor: p.ink.withValues(alpha: 0.03),
    );
  }
}
