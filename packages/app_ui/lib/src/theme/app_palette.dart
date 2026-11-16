import 'package:app_ui/src/theme/app_colors.dart';
import 'package:app_ui/src/theme/app_shadows.dart';
import 'package:app_ui/src/theme/app_tone.dart';
import 'package:material_ui/material_ui.dart';

/// {@template app_palette}
/// The semantic colors of one theme.
///
/// [AppColors] holds the raw Figma palette, which never changes. This is the
/// layer the widgets read: every role here has a value for the light panel and
/// another for the dark one, so a widget asks for `context.colors.ink` and
/// never for a hex.
///
/// The palette rides on the [ThemeData] as a [ThemeExtension], which is what
/// makes it follow `themeMode` without a single `if`.
/// {@endtemplate}
class AppPalette extends ThemeExtension<AppPalette> {
  /// {@macro app_palette}
  const AppPalette({
    required this.brightness,
    required this.accent,
    required this.accentInk,
    required this.accentSoft,
    required this.onPrimary,
    required this.onAccent,
    required this.success,
    required this.successLight,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
    required this.danger,
    required this.dangerSoft,
    required this.surfaceRaised,
    required this.surface,
    required this.fill,
    required this.fillWarm,
    required this.surfaceContainerHigh,
    required this.fillStrong,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.line,
    required this.overlayOnTint,
    required this.overlayOnTintStrong,
    required this.errorOutline,
    required this.onErrorContainer,
    required this.spark,
    required this.bezel,
    required this.bezelEdge,
    required this.shadows,
    required this.tones,
  });

  /// The brightness this palette paints.
  final Brightness brightness;

  /// The single brand accent.
  final Color accent;

  /// A darker accent, for text that needs contrast on a tint.
  final Color accentInk;

  /// A soft accent tint, for accent-washed fills.
  final Color accentSoft;

  /// Content drawn on top of the ink fill.
  final Color onPrimary;

  /// Content drawn on top of [accent].
  final Color onAccent;

  /// Healthy, done, on track.
  final Color success;

  /// A lighter [success] for what glows or sits on a surface.
  final Color successLight;

  /// A soft [success] tint.
  final Color successSoft;

  /// Needs attention soon.
  final Color warning;

  /// A soft [warning] tint.
  final Color warningSoft;

  /// Needs attention now.
  final Color danger;

  /// A soft [danger] tint.
  final Color dangerSoft;

  /// The raised card surface.
  final Color surfaceRaised;

  /// The page background behind every screen.
  final Color surface;

  /// A borderless fill for chips and inline surfaces.
  final Color fill;

  /// A warm fill for pills and buttons that sit on a card.
  final Color fillWarm;

  /// A slightly stronger fill.
  final Color surfaceContainerHigh;

  /// A heavier [fill], for tracks and inactive bars.
  final Color fillStrong;

  /// Primary text.
  final Color ink;

  /// Secondary text.
  final Color ink2;

  /// Tertiary text.
  final Color ink3;

  /// Hairline separators.
  final Color line;

  /// The veil laid over a tinted card for chips, bubbles and controls.
  final Color overlayOnTint;

  /// A stronger [overlayOnTint].
  final Color overlayOnTintStrong;

  /// The border of an urgent card.
  final Color errorOutline;

  /// Text on an urgent card's wash.
  final Color onErrorContainer;

  /// The sparkle that marks anything the assistant offers.
  final Color spark;

  /// The dark bezel around the panel. Hardware, so it never turns light.
  final Color bezel;

  /// The bezel's edge highlight.
  final Color bezelEdge;

  /// The elevation tokens, which are softer in the dark.
  final AppShadowSet shadows;

  /// The color of each [AppTone]'s wash, ink and accent.
  final Map<AppTone, ToneColors> tones;

  /// The palette of the light panel: the original Figma values.
  static const light = AppPalette(
    brightness: Brightness.light,
    accent: AppColors.accent,
    accentInk: AppColors.accentInk,
    accentSoft: AppColors.accentSoft,
    onPrimary: AppColors.onPrimary,
    onAccent: AppColors.onAccent,
    success: AppColors.success,
    successLight: AppColors.successLight,
    successSoft: AppColors.successSoft,
    warning: AppColors.warning,
    warningSoft: AppColors.warningSoft,
    danger: AppColors.danger,
    dangerSoft: AppColors.dangerSoft,
    surfaceRaised: AppColors.surfaceRaised,
    surface: AppColors.surface,
    fill: AppColors.fill,
    fillWarm: AppColors.fillWarm,
    surfaceContainerHigh: AppColors.surfaceContainerHigh,
    fillStrong: AppColors.fillStrong,
    ink: AppColors.ink,
    ink2: AppColors.ink2,
    ink3: AppColors.ink3,
    line: AppColors.line,
    overlayOnTint: AppColors.overlayOnTint,
    overlayOnTintStrong: AppColors.overlayOnTintStrong,
    errorOutline: AppColors.errorOutline,
    onErrorContainer: AppColors.onErrorContainer,
    spark: AppColors.spark,
    bezel: AppColors.bezel,
    bezelEdge: AppColors.bezelEdge,
    shadows: AppShadowSet.light,
    tones: _lightTones,
  );

  /// The palette of the dark panel: the same roles, inverted, so the panel can
  /// hang on a wall at night without glowing white.
  static const dark = AppPalette(
    brightness: Brightness.dark,
    accent: Color(0xFF7D97FF),
    accentInk: Color(0xFFC9D5FF),
    accentSoft: Color(0xFF1C2547),
    onPrimary: Color(0xFF0B1020),
    onAccent: Color(0xFF0B1020),
    success: Color(0xFF7DFF7D),
    successLight: Color(0xFF34C759),
    successSoft: Color(0xFF14301A),
    warning: AppColors.brandYellow200,
    warningSoft: Color(0xFF33290A),
    danger: Color(0xFFFF8A5C),
    dangerSoft: Color(0xFF3A1D14),
    surfaceRaised: Color(0xFF171B24),
    surface: Color(0xFF0E1118),
    fill: Color(0xFF2A3040),
    fillWarm: Color(0xFF242833),
    surfaceContainerHigh: Color(0xFF232838),
    fillStrong: Color(0xFF4A5265),
    ink: Color(0xFFF2F4FA),
    ink2: Color(0xFFA7AEBD),
    ink3: Color(0xFF8A91A0),
    line: Color(0xFF2B3140),
    overlayOnTint: Color(0x1AFFFFFF),
    overlayOnTintStrong: Color(0x33FFFFFF),
    errorOutline: Color(0xCCFF8A5C),
    onErrorContainer: Color(0xFFFFD9CC),
    spark: Color(0xFFFFC078),
    bezel: Color(0xFF0A0C12),
    bezelEdge: Color(0xFF2A2D34),
    shadows: AppShadowSet.dark,
    tones: _darkTones,
  );

  static const _lightTones = <AppTone, ToneColors>{
    AppTone.neutral: ToneColors(ink: AppColors.ink, accent: AppColors.accent),
    AppTone.lighting: ToneColors(
      wash: AppColors.brandYellow100,
      ink: AppColors.brandYellow300,
      accent: AppColors.brandYellow200,
    ),
    AppTone.energy: ToneColors(
      wash: AppColors.brandGreen100,
      ink: AppColors.brandGreen300,
      accent: AppColors.brandGreen300,
    ),
    AppTone.climate: ToneColors(
      wash: AppColors.brandOrange100,
      ink: AppColors.brandOrange300,
      accent: AppColors.brandOrange200,
    ),
    AppTone.security: ToneColors(
      wash: AppColors.brandBlue100,
      ink: AppColors.brandBlue300,
      accent: AppColors.brandBlue200,
    ),
    AppTone.weather: ToneColors(
      wash: AppColors.brandAqua100,
      ink: AppColors.brandAqua300,
      accent: AppColors.brandAqua200,
    ),
  };

  // The washes turn translucent over the dark card instead of filling it, and
  // the ink flips to the pale end of each hue.
  static const _darkTones = <AppTone, ToneColors>{
    AppTone.neutral: ToneColors(
      ink: Color(0xFFF2F4FA),
      accent: Color(0xFF7D97FF),
    ),
    AppTone.lighting: ToneColors(
      wash: Color(0x33EBB727),
      ink: Color(0xFFFFEBC7),
      accent: AppColors.brandYellow200,
    ),
    AppTone.energy: ToneColors(
      wash: Color(0x337DFF7D),
      ink: Color(0xFFE6FFE6),
      accent: AppColors.brandGreen200,
    ),
    AppTone.climate: ToneColors(
      wash: Color(0x33F07239),
      ink: Color(0xFFFEE5D9),
      accent: AppColors.brandOrange200,
    ),
    AppTone.security: ToneColors(
      wash: Color(0x332E56FF),
      ink: Color(0xFFDEE7FF),
      accent: Color(0xFF8CA3FF),
    ),
    AppTone.weather: ToneColors(
      wash: Color(0x333FCFFF),
      ink: Color(0xFFDFF7FF),
      accent: AppColors.brandAqua200,
    ),
  };

  /// The palette of the [Theme] above [context], or the one that matches the
  /// ambient brightness when no [AppPalette] was registered.
  static AppPalette of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<AppPalette>() ??
        (theme.brightness == Brightness.dark ? dark : light);
  }

  /// The colors of [tone] in this palette.
  ToneColors tone(AppTone tone) => tones[tone] ?? tones[AppTone.neutral]!;

  /// The palette with the given roles replaced.
  @override
  AppPalette copyWith({
    Color? accent,
    Color? accentInk,
    Color? accentSoft,
    Color? onPrimary,
    Color? onAccent,
    Color? success,
    Color? successLight,
    Color? successSoft,
    Color? warning,
    Color? warningSoft,
    Color? danger,
    Color? dangerSoft,
    Color? surfaceRaised,
    Color? surface,
    Color? fill,
    Color? fillWarm,
    Color? surfaceContainerHigh,
    Color? fillStrong,
    Color? ink,
    Color? ink2,
    Color? ink3,
    Color? line,
    Color? overlayOnTint,
    Color? overlayOnTintStrong,
    Color? errorOutline,
    Color? onErrorContainer,
    Color? spark,
    Color? bezel,
    Color? bezelEdge,
    AppShadowSet? shadows,
    Map<AppTone, ToneColors>? tones,
  }) {
    return AppPalette(
      brightness: brightness,
      accent: accent ?? this.accent,
      accentInk: accentInk ?? this.accentInk,
      accentSoft: accentSoft ?? this.accentSoft,
      onPrimary: onPrimary ?? this.onPrimary,
      onAccent: onAccent ?? this.onAccent,
      success: success ?? this.success,
      successLight: successLight ?? this.successLight,
      successSoft: successSoft ?? this.successSoft,
      warning: warning ?? this.warning,
      warningSoft: warningSoft ?? this.warningSoft,
      danger: danger ?? this.danger,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surface: surface ?? this.surface,
      fill: fill ?? this.fill,
      fillWarm: fillWarm ?? this.fillWarm,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      fillStrong: fillStrong ?? this.fillStrong,
      ink: ink ?? this.ink,
      ink2: ink2 ?? this.ink2,
      ink3: ink3 ?? this.ink3,
      line: line ?? this.line,
      overlayOnTint: overlayOnTint ?? this.overlayOnTint,
      overlayOnTintStrong: overlayOnTintStrong ?? this.overlayOnTintStrong,
      errorOutline: errorOutline ?? this.errorOutline,
      onErrorContainer: onErrorContainer ?? this.onErrorContainer,
      spark: spark ?? this.spark,
      bezel: bezel ?? this.bezel,
      bezelEdge: bezelEdge ?? this.bezelEdge,
      shadows: shadows ?? this.shadows,
      tones: tones ?? this.tones,
    );
  }

  /// Blends every role towards [other], so a theme switch can animate.
  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    ToneColors mixTone(ToneColors a, ToneColors b) => ToneColors(
      wash: Color.lerp(a.wash, b.wash, t),
      ink: mix(a.ink, b.ink),
      accent: mix(a.accent, b.accent),
    );
    return AppPalette(
      brightness: t <= 0.5 ? brightness : other.brightness,
      accent: mix(accent, other.accent),
      accentInk: mix(accentInk, other.accentInk),
      accentSoft: mix(accentSoft, other.accentSoft),
      onPrimary: mix(onPrimary, other.onPrimary),
      onAccent: mix(onAccent, other.onAccent),
      success: mix(success, other.success),
      successLight: mix(successLight, other.successLight),
      successSoft: mix(successSoft, other.successSoft),
      warning: mix(warning, other.warning),
      warningSoft: mix(warningSoft, other.warningSoft),
      danger: mix(danger, other.danger),
      dangerSoft: mix(dangerSoft, other.dangerSoft),
      surfaceRaised: mix(surfaceRaised, other.surfaceRaised),
      surface: mix(surface, other.surface),
      fill: mix(fill, other.fill),
      fillWarm: mix(fillWarm, other.fillWarm),
      surfaceContainerHigh: mix(
        surfaceContainerHigh,
        other.surfaceContainerHigh,
      ),
      fillStrong: mix(fillStrong, other.fillStrong),
      ink: mix(ink, other.ink),
      ink2: mix(ink2, other.ink2),
      ink3: mix(ink3, other.ink3),
      line: mix(line, other.line),
      overlayOnTint: mix(overlayOnTint, other.overlayOnTint),
      overlayOnTintStrong: mix(
        overlayOnTintStrong,
        other.overlayOnTintStrong,
      ),
      errorOutline: mix(errorOutline, other.errorOutline),
      onErrorContainer: mix(onErrorContainer, other.onErrorContainer),
      spark: mix(spark, other.spark),
      bezel: mix(bezel, other.bezel),
      bezelEdge: mix(bezelEdge, other.bezelEdge),
      shadows: AppShadowSet.lerp(shadows, other.shadows, t),
      tones: {
        for (final each in AppTone.values)
          each: mixTone(tone(each), other.tone(each)),
      },
    );
  }
}

/// The semantic colors read from the theme above a [BuildContext].
extension AppPaletteContext on BuildContext {
  /// The palette of the theme above this context.
  AppPalette get colors => AppPalette.of(this);
}
