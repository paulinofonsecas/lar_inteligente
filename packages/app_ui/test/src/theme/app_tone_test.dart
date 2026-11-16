import 'package:app_ui/app_ui.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(AppTone, () {
    test('byName finds a tone', () {
      expect(AppTone.byName('energy'), AppTone.energy);
    });

    test('byName falls back for null and unknown names', () {
      expect(AppTone.byName(null), AppTone.neutral);
      expect(AppTone.byName('pink'), AppTone.neutral);
      expect(
        AppTone.byName('pink', fallback: AppTone.lighting),
        AppTone.lighting,
      );
    });

    test('neutral has no wash and no gradient', () {
      final colors = AppPalette.light.tone(AppTone.neutral);

      expect(colors.wash, isNull);
      expect(colors.gradient, isNull);
    });

    test('every other tone washes from the top right', () {
      for (final palette in [AppPalette.light, AppPalette.dark]) {
        for (final tone in AppTone.values.where((t) => t != AppTone.neutral)) {
          final colors = palette.tone(tone);
          final gradient = colors.gradient! as RadialGradient;
          expect(gradient.center, Alignment.topRight);
          expect(gradient.colors.first, colors.wash);
        }
      }
    });
  });
}
