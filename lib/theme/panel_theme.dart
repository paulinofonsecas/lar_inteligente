import 'package:a2ui_vgv_smart_home/timeline/day_phase.dart';
import 'package:material_ui/material_ui.dart';

/// {@template panel_theme}
/// How the panel picks its appearance: always light, always dark, or with the
/// time of day on the timeline.
///
/// [auto] is the one the panel opens on: it follows the clock as the demo
/// plays, and the phases the timeline's buttons jump to, so the panel is light
/// from the morning to the sunset and dark once it is evening.
/// {@endtemplate}
enum PanelTheme {
  /// The light theme all day, whatever the time is.
  light,

  /// The dark theme all day, whatever the time is.
  dark,

  /// Follows the time on the timeline, see [modeFor].
  auto;

  /// The mode to draw when the demo's time is in [phase].
  ThemeMode modeFor(DayPhase phase) => switch (this) {
    light => ThemeMode.light,
    dark => ThemeMode.dark,
    auto => phase == DayPhase.evening ? ThemeMode.dark : ThemeMode.light,
  };

  /// The theme called [name], or null when nothing matches it. The panel used
  /// to save the device's own setting under `system`, which reads as [auto].
  static PanelTheme? byName(String? name) => switch (name) {
    'system' => auto,
    _ => values.where((theme) => theme.name == name).firstOrNull,
  };
}
