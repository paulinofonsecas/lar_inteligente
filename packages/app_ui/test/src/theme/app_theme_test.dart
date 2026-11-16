import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group(AppTheme, () {
    test('builds the scheme from the accent token', () {
      final theme = AppTheme.light;

      expect(theme.colorScheme.primary, AppColors.accent);
      expect(theme.scaffoldBackgroundColor, AppColors.surface);
    });

    test('derives the text theme from the type scale', () {
      expect(AppTheme.light.textTheme.titleLarge?.fontSize, 28);
    });

    test('builds the dark scheme from the dark palette', () {
      final theme = AppTheme.dark;

      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, AppPalette.dark.surface);
      expect(theme.colorScheme.primary, AppPalette.dark.accent);
      expect(theme.textTheme.bodyMedium?.color, AppPalette.dark.ink);
    });

    test('registers the palette as a theme extension', () {
      expect(AppTheme.light.extension<AppPalette>(), AppPalette.light);
      expect(AppTheme.dark.extension<AppPalette>(), AppPalette.dark);
    });
  });

  group(AppIcons, () {
    test('resolves a known name', () {
      expect(AppIcons.byName('oven'), isNot(AppIcons.fallback));
    });

    test('falls back for an unknown or missing name', () {
      expect(AppIcons.byName('nope'), AppIcons.fallback);
      expect(AppIcons.byName(null), AppIcons.fallback);
    });

    test('lists every name', () {
      expect(AppIcons.names, contains('fridge'));
    });
  });
}
