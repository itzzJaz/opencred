import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencred/app_theme.dart';

/// WCAG relative contrast. AA for normal text is 4.5:1.
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final high = math.max(la, lb);
  final low = math.min(la, lb);
  return (high + 0.05) / (low + 0.05);
}

void main() {
  test('primary buttons keep their label readable in both themes', () {
    for (final theme in [OpenCredTheme.light(), OpenCredTheme.dark()]) {
      final style = theme.filledButtonTheme.style!;
      final fill = style.backgroundColor!.resolve({})!;
      final label = style.foregroundColor!.resolve({})!;
      expect(fill, isNot(label),
          reason: '${theme.brightness} button fill and label are the same');
      expect(_contrast(fill, label), greaterThanOrEqualTo(4.5),
          reason: '${theme.brightness} button label is below AA contrast');
    }
  });

  test('ink surfaces and their content are readable in both themes', () {
    for (final palette in [Palette.light, Palette.dark]) {
      expect(_contrast(palette.ink, palette.onInk), greaterThanOrEqualTo(4.5));
      expect(_contrast(palette.canvas, palette.ink), greaterThanOrEqualTo(4.5));
      expect(
          _contrast(palette.hero, palette.onHero), greaterThanOrEqualTo(4.5));
    }
  });

  test('the active theme follows the requested mode', () {
    final light = OpenCredTheme.light();
    final dark = OpenCredTheme.dark();
    expect(light.brightness, Brightness.light);
    expect(dark.brightness, Brightness.dark);
    expect(light.scaffoldBackgroundColor, Palette.light.canvas);
    expect(dark.scaffoldBackgroundColor, Palette.dark.canvas);
  });
}
