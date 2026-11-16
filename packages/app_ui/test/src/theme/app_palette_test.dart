import 'dart:math';

import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// The WCAG relative luminance of [color].
double _luminance(Color color) {
  double channel(double value) => value <= 0.03928
      ? value / 12.92
      : pow((value + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

/// The WCAG contrast ratio between [a] and [b].
double _contrast(Color a, Color b) {
  final first = _luminance(a);
  final second = _luminance(b);
  final lighter = max(first, second);
  final darker = min(first, second);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group(AppPalette, () {
    test('the light palette keeps the Figma values', () {
      const palette = AppPalette.light;

      expect(palette.surface, AppColors.surface);
      expect(palette.surfaceRaised, AppColors.surfaceRaised);
      expect(palette.ink, AppColors.ink);
      expect(palette.ink2, AppColors.ink2);
      expect(palette.accent, AppColors.accent);
      expect(palette.danger, AppColors.danger);
      expect(palette.line, AppColors.line);
      expect(palette.brightness, Brightness.light);
    });

    test('the dark palette flips the surfaces and the ink', () {
      const palette = AppPalette.dark;

      expect(palette.brightness, Brightness.dark);
      expect(_luminance(palette.surface), lessThan(0.05));
      expect(_luminance(palette.ink), greaterThan(0.7));
      expect(palette.surface, isNot(AppPalette.light.surface));
    });

    test('the bezel stays hardware-dark in both themes', () {
      expect(_luminance(AppPalette.light.bezel), lessThan(0.05));
      expect(_luminance(AppPalette.dark.bezel), lessThan(0.05));
    });

    test('every tone resolves in both palettes', () {
      for (final palette in [AppPalette.light, AppPalette.dark]) {
        for (final tone in AppTone.values) {
          final colors = palette.tone(tone);
          expect(colors.ink, isNotNull, reason: '${palette.brightness} $tone');
          expect(
            colors.accent,
            isNotNull,
            reason: '${palette.brightness} $tone',
          );
        }
      }
    });

    test('the dark washes are translucent, so the card still reads', () {
      for (final tone in AppTone.values) {
        final wash = AppPalette.dark.tone(tone).wash;
        if (wash == null) continue;
        expect(wash.a, lessThan(0.5), reason: '$tone');
      }
    });

    test('text reads on the surfaces at WCAG AA in both themes', () {
      for (final palette in [AppPalette.light, AppPalette.dark]) {
        final reason = '${palette.brightness}';
        expect(
          _contrast(palette.ink, palette.surfaceRaised),
          greaterThanOrEqualTo(4.5),
          reason: '$reason ink on the card',
        );
        expect(
          _contrast(palette.ink, palette.surface),
          greaterThanOrEqualTo(4.5),
          reason: '$reason ink on the page',
        );
        // The light design's secondary ink sits at 3.5:1 on the card, which
        // is AA for large text only; the dark palette must not fall below it.
        expect(
          _contrast(palette.ink2, palette.surfaceRaised),
          greaterThanOrEqualTo(3.4),
          reason: '$reason secondary ink on the card',
        );
        expect(
          _contrast(palette.ink3, palette.surfaceRaised),
          greaterThanOrEqualTo(3),
          reason: '$reason tertiary ink on the card',
        );
        expect(
          _contrast(palette.onAccent, palette.accent),
          greaterThanOrEqualTo(4.5),
          reason: '$reason accent content on the accent',
        );
        expect(
          _contrast(palette.onPrimary, palette.ink),
          greaterThanOrEqualTo(4.5),
          reason: '$reason ink content on the ink fill',
        );
      }
    });

    test('every tone ink reads on its own wash', () {
      for (final palette in [AppPalette.light, AppPalette.dark]) {
        for (final tone in AppTone.values) {
          final colors = palette.tone(tone);
          final wash = colors.wash;
          final background = wash == null
              ? palette.surfaceRaised
              : Color.alphaBlend(wash, palette.surfaceRaised);
          expect(
            _contrast(colors.ink, background),
            greaterThanOrEqualTo(3),
            reason: '${palette.brightness} $tone',
          );
        }
      }
    });

    test('copyWith and lerp keep the palette whole', () {
      final palette = AppPalette.light.copyWith(ink: const Color(0xFF000000));
      expect(palette.ink, const Color(0xFF000000));
      expect(palette.surface, AppPalette.light.surface);

      final middle = AppPalette.light.lerp(AppPalette.dark, 0.5);
      expect(middle.ink, isNot(AppPalette.light.ink));
      expect(middle.ink, isNot(AppPalette.dark.ink));
      expect(middle.brightness, Brightness.light);
      expect(AppPalette.light.lerp(null, 0.5), AppPalette.light);
    });
  });
}
