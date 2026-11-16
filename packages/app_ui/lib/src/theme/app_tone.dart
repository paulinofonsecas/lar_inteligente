import 'package:material_ui/material_ui.dart';

/// {@template tone_colors}
/// The three colors of one [AppTone]: the wash laid over the card, the ink
/// that reads on it, and the saturated accent for switches and icon bubbles.
/// {@endtemplate}
class ToneColors {
  /// {@macro tone_colors}
  const ToneColors({required this.ink, required this.accent, this.wash});

  /// The wash color, or null when the card keeps its surface.
  final Color? wash;

  /// Text and icon color that reads on [wash].
  final Color ink;

  /// The saturated color, for switches and icon bubbles.
  final Color accent;

  /// The decoration painted over the card surface, or null without a [wash].
  Gradient? get gradient {
    final wash = this.wash;
    if (wash == null) return null;
    return RadialGradient(
      center: Alignment.topRight,
      radius: 1.3,
      colors: [wash, wash.withValues(alpha: 0)],
    );
  }
}

/// {@template app_tone}
/// The color of a card, chosen by the kind of device or message.
///
/// A closed set that mirrors the catalog's `tone` enum: the model never sends
/// colors. Each tone is a wash from the top right of the card over its
/// surface; the palette decides what those colors are in each theme, through
/// `AppPalette.tone`.
/// {@endtemplate}
enum AppTone {
  /// The card surface, no wash.
  neutral,

  /// Scenes, lights, countdowns, blinds.
  lighting,

  /// The car and the energy meter.
  energy,

  /// Thermostats and heat.
  climate,

  /// Locks, garage, doorbell.
  security,

  /// Outside weather.
  weather;

  /// The tone named [name], or [fallback] when it is null or unknown.
  static AppTone byName(String? name, {AppTone fallback = neutral}) {
    for (final tone in values) {
      if (tone.name == name) return tone;
    }
    return fallback;
  }
}
