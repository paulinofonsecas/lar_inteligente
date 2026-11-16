import 'package:a2ui_vgv_smart_home/theme/panel_theme.dart';
import 'package:a2ui_vgv_smart_home/timeline/day_phase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group(PanelTheme, () {
    test('keeps the light theme all day when it is fixed', () {
      for (final phase in DayPhase.values) {
        expect(PanelTheme.light.modeFor(phase), ThemeMode.light);
      }
    });

    test('keeps the dark theme all day when it is fixed', () {
      for (final phase in DayPhase.values) {
        expect(PanelTheme.dark.modeFor(phase), ThemeMode.dark);
      }
    });

    test('follows the time: light by day, dark once it is evening', () {
      expect(PanelTheme.auto.modeFor(DayPhase.morning), ThemeMode.light);
      expect(PanelTheme.auto.modeFor(DayPhase.day), ThemeMode.light);
      expect(PanelTheme.auto.modeFor(DayPhase.sunset), ThemeMode.light);
      expect(PanelTheme.auto.modeFor(DayPhase.evening), ThemeMode.dark);
    });

    test('byName reads the saved names, and the old system one as auto', () {
      expect(PanelTheme.byName('light'), PanelTheme.light);
      expect(PanelTheme.byName('dark'), PanelTheme.dark);
      expect(PanelTheme.byName('auto'), PanelTheme.auto);
      expect(PanelTheme.byName('system'), PanelTheme.auto);
      expect(PanelTheme.byName(null), isNull);
      expect(PanelTheme.byName('other'), isNull);
    });
  });
}
