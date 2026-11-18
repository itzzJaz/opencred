import 'package:flutter/material.dart';

/// Spacing scale. Every margin, padding and gap is a multiple of 4.
/// A 2px step is only allowed for an optical nudge inside a control.
abstract final class Spacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

/// Corner geometry. Controls are capsules, containers are soft rounded rects.
abstract final class Radii {
  static const double card = 22;
  static const double field = 12;
  static const double row = 8;
  static const double capsule = 1000;
}

abstract final class Layout {
  static const double pageGutter = 24;

  /// Height of one destination inside the floating nav pill.
  static const double navItemHeight = 56;

  /// Space reserved at the end of every scrolling canvas for the nav pill.
  static const double pageBottomInset = 104;
}

/// The product's palette: warm ivory paper, deep emerald ink and a champagne
/// gold detail. The proportions are deliberate: ivory carries the canvas,
/// emerald carries text and primary surfaces, gold is used only for small
/// marks, the score arc and focus states.
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

  /// Borders are a quiet hairline, never a colored stroke.
  final Color hairline;
  final Color ink;

  /// The colour that sits on top of [ink] surfaces: primary buttons, the
  /// selected nav item and the selected filter pill. In dark mode [ink] is
  /// ivory, so this is the deep-emerald canvas, not another ivory.
  final Color onInk;
  final Color secondary;
  final Color muted;

  /// Champagne gold. Never body text on ivory; it is a foil mark, not a hue
  /// for paragraphs.
  final Color accent;
  final Color onAccent;
  final Color accentTint;
  final Color positive;
  final Color warning;
  final Color negative;

  /// The one dark surface in the app, used by the overview statement card.
  final Color hero;
  final Color onHero;

  bool get isDark => brightness == Brightness.dark;

  static Palette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  static const light = Palette(
    brightness: Brightness.light,
    canvas: Color(0xFFF6F4ED),
    surface: Color(0xFFFCFAF4),
    raised: Color(0xFFEDE9DD),
    hairline: Color(0x1A173B35),
    ink: Color(0xFF173B35),
    onInk: Color(0xFFF6F4ED),
    secondary: Color(0xFF4B615A),
    muted: Color(0xFF6D7F78),
    accent: Color(0xFFD7A94B),
    onAccent: Color(0xFF173B35),
    accentTint: Color(0x33D7A94B),
    positive: Color(0xFF2F6A57),
    warning: Color(0xFFA87B28),
    negative: Color(0xFFA6483A),
    hero: Color(0xFF173B35),
    onHero: Color(0xFFF6F4ED),
  );

  static const dark = Palette(
    brightness: Brightness.dark,
    canvas: Color(0xFF0C1B18),
    surface: Color(0xFF102420),
    raised: Color(0xFF17302A),
    hairline: Color(0x29F2EFE4),
    ink: Color(0xFFF2EFE4),
    onInk: Color(0xFF0C1B18),
    secondary: Color(0xFFA8B8B0),
    muted: Color(0xFF80938B),
    accent: Color(0xFFD9B264),
    onAccent: Color(0xFF173B35),
    accentTint: Color(0x33D9B264),
    positive: Color(0xFF74B79B),
    warning: Color(0xFFD9B264),
    negative: Color(0xFFD9887A),
    hero: Color(0xFF091512),
    onHero: Color(0xFFF2EFE4),
  );
}

class OpenCredTheme {
  static ThemeData light() => _build(Palette.light);

  static ThemeData dark() => _build(Palette.dark);

  /// Hierarchy comes from size and color. Nothing goes past w600, and every
  /// style carries tabular figures so scores and metrics line up in a column.
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
      headlineMedium: _style(p, 30, 1.15, FontWeight.w600, -0.6),
      headlineSmall: _style(p, 22, 1.2, FontWeight.w600, -0.3),
      titleLarge: _style(p, 20, 1.25, FontWeight.w600, -0.2),
      titleMedium: _style(p, 16, 1.3, FontWeight.w600),
      bodyLarge: _style(p, 16, 1.45, FontWeight.w400),
      bodyMedium: _style(p, 14, 1.45, FontWeight.w400),
      bodySmall: _style(p, 13, 1.4, FontWeight.w400),
      labelLarge: _style(p, 15, 1.2, FontWeight.w600),
      labelMedium: _style(p, 13, 1.2, FontWeight.w500),
      labelSmall: _style(p, 12, 1.33, FontWeight.w500),
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
          borderRadius: BorderRadius.circular(Radii.card),
          side: BorderSide(color: p.hairline),
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
          textStyle: _style(p, 15, 1.2, FontWeight.w600),
          shape: const StadiumBorder(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.ink,
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          textStyle: _style(p, 14, 1.2, FontWeight.w600),
          shape: const StadiumBorder(),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: 14,
        ),
        hintStyle: TextStyle(color: p.muted, fontSize: 15),
        labelStyle: TextStyle(color: p.secondary, fontSize: 15),
        floatingLabelStyle: TextStyle(
          color: p.ink,
          fontSize: 13,
          fontWeight: FontWeight.w500,
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
        color: p.positive,
        linearTrackColor: p.raised,
        circularTrackColor: p.raised,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.ink,
        selectionColor: p.accent.withValues(alpha: 0.28),
        selectionHandleColor: p.ink,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.ink,
        contentTextStyle: TextStyle(color: p.onInk, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.field),
        ),
      ),
      splashColor: p.ink.withValues(alpha: 0.04),
      highlightColor: p.ink.withValues(alpha: 0.03),
    );
  }
}
