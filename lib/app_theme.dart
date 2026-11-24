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

/// Razor-sharp geometric corner radii (4px flat architectural / motorsport style).
abstract final class Radii {
  static const double card = 4;
  static const double field = 4;
  static const double row = 2;
  static const double capsule = 4;
}

abstract final class Layout {
  static const double pageGutter = 20;
  static const double navItemHeight = 54;
  static const double pageBottomInset = 96;
}

/// Flat, razor-sharp motorsport/Swiss editorial palette.
/// Editorial Paper Off-White (#F2F2F0), Matte Dark Ink (#111214),
/// Flat Architectural Grey (#E6E6E2), and UN SDG 1 Crimson (#E5243B).
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

  /// UN SDG 1 Crimson (#E5243B) signature accent.
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
    canvas: Color(0xFFF2F2F0), // Editorial Paper Off-White
    surface: Color(0xFFE6E6E2), // Flat Architectural Grey
    raised: Color(0xFFDADAD4),
    hairline: Color(0x1F111214), // 12% ink hairline
    ink: Color(0xFF111214), // Matte Dark Ink
    onInk: Color(0xFFF2F2F0),
    secondary: Color(0xFF55575E),
    muted: Color(0xFF7E8088),
    accent: Color(0xFFE5243B), // UN SDG 1 Crimson
    onAccent: Color(0xFFFFFFFF),
    accentTint: Color(0x26E5243B),
    positive: Color(0xFF1B6A4C), // High contrast forest emerald
    warning: Color(0xFF5375A8),
    negative: Color(0xFFE5243B),
    hero: Color(0xFF111214),
    onHero: Color(0xFFF2F2F0),
  );

  static const dark = Palette(
    brightness: Brightness.dark,
    canvas: Color(0xFF111214), // Matte Dark Ink
    surface: Color(0xFF1B1C20),
    raised: Color(0xFF25272D),
    hairline: Color(0x1FFFFFFF), // 12% white hairline
    ink: Color(0xFFF2F2F0), // Paper Off-White
    onInk: Color(0xFF111214),
    secondary: Color(0xFFA0A3AD),
    muted: Color(0xFF6E717B),
    accent: Color(0xFFE5243B), // UN SDG 1 Crimson
    onAccent: Color(0xFFFFFFFF),
    accentTint: Color(0x33E5243B),
    positive: Color(0xFF34D399),
    warning: Color(0xFF91B8EF),
    negative: Color(0xFFF87171),
    hero: Color(0xFF090A0C),
    onHero: Color(0xFFF2F2F0),
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
        color: p.ink,
        fontSize: size,
        height: height,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static OutlineInputBorder _fieldBorder(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.field),
        borderSide: BorderSide(color: color, width: width),
      );

  static ThemeData _build(Palette p) {
    final scheme =
        ColorScheme.fromSeed(seedColor: p.ink, brightness: p.brightness)
            .copyWith(
      primary: p.ink,
      onPrimary: p.onInk,
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
      headlineLarge: _style(p, 36, 0.98, FontWeight.w800, -1.2),
      headlineMedium: _style(p, 28, 1.04, FontWeight.w700, -0.8),
      headlineSmall: _style(p, 22, 1.12, FontWeight.w700, -0.4),
      titleLarge: _style(p, 19, 1.2, FontWeight.w700, -0.2),
      titleMedium: _style(p, 15, 1.25, FontWeight.w600),
      bodyLarge: _style(p, 15, 1.45, FontWeight.w400),
      bodyMedium: _style(p, 13.5, 1.45, FontWeight.w400),
      bodySmall: _style(p, 12, 1.4, FontWeight.w400),
      labelLarge: _style(p, 14, 1.2, FontWeight.w700, 0.4),
      labelMedium: _style(p, 12, 1.2, FontWeight.w600, 0.2),
      labelSmall: _style(p, 10.5, 1.3, FontWeight.w600, 0.5),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.canvas,
      textTheme: text.apply(bodyColor: p.ink, displayColor: p.ink),
      iconTheme: IconThemeData(color: p.secondary, size: 20),
      // Flat card: 0 elevation, 0 shadow, 4px minimal radius, 1px crisp hairline
      cardTheme: CardThemeData(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.card),
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
          backgroundColor: p.ink,
          foregroundColor: p.onInk,
          disabledBackgroundColor: p.raised,
          disabledForegroundColor: p.muted,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          elevation: 0,
          textStyle: _style(p, 14, 1.2, FontWeight.w700, 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.card),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.ink,
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          textStyle: _style(p, 13.5, 1.2, FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.card),
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
        backgroundColor: p.ink,
        contentTextStyle: TextStyle(color: p.onInk, fontSize: 13.5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.card),
        ),
      ),
      splashColor: p.ink.withValues(alpha: 0.04),
      highlightColor: p.ink.withValues(alpha: 0.03),
    );
  }
}
