import 'package:app_ui/src/theme/app_palette.dart';
import 'package:app_ui/src/theme/app_spacing.dart';
import 'package:app_ui/src/theme/app_typography.dart';
import 'package:material_ui/material_ui.dart';

/// {@template app_theme}
/// The panel themes: the light one the Figma file draws, and the dark one that
/// lets the same panel hang on a wall at night.
///
/// Both are built from one [AppPalette], which also rides along as a theme
/// extension so the widgets can read `context.colors` without a second source
/// of truth.
/// {@endtemplate}
abstract final class AppTheme {
  /// The light [ThemeData] of the panel.
  static ThemeData get light => _build(AppPalette.light);

  /// The dark [ThemeData] of the panel.
  static ThemeData get dark => _build(AppPalette.dark);

  static ThemeData _build(AppPalette palette) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: palette.accent,
          brightness: palette.brightness,
          primary: palette.accent,
          onPrimary: palette.onAccent,
        ).copyWith(
          surface: palette.surface,
          onSurface: palette.ink,
          surfaceContainerHighest: palette.fill,
          onSurfaceVariant: palette.ink2,
          outlineVariant: palette.line,
          error: palette.danger,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: palette.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.surface,
      textTheme: AppTypography.textTheme(palette),
      extensions: [palette],
      appBarTheme: AppBarTheme(
        backgroundColor: palette.surface,
        foregroundColor: palette.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.title,
      ),
      cardTheme: CardThemeData(
        color: palette.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppSpacing.cardRadius),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: palette.line,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.accent,
          foregroundColor: palette.onAccent,
          minimumSize: const Size(0, AppSpacing.tapTarget),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s6),
          textStyle: AppTypography.body,
          shape: const StadiumBorder(),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.fill,
          foregroundColor: palette.ink,
          elevation: 0,
          minimumSize: const Size(0, AppSpacing.tapTarget),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s6),
          textStyle: AppTypography.body,
          shape: const StadiumBorder(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.ink,
          minimumSize: const Size(0, AppSpacing.tapTarget),
          textStyle: AppTypography.body,
          shape: const StadiumBorder(),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: palette.fill,
          foregroundColor: palette.ink2,
          selectedBackgroundColor: palette.accent,
          selectedForegroundColor: palette.onAccent,
          side: BorderSide.none,
          textStyle: AppTypography.labelStrong,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.fill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s5,
          vertical: AppSpacing.s3,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(color: palette.ink3),
        border: _fieldBorder(),
        enabledBorder: _fieldBorder(),
        focusedBorder: _fieldBorder(color: palette.accent),
        errorBorder: _fieldBorder(color: palette.danger),
        focusedErrorBorder: _fieldBorder(color: palette.danger),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.accent,
        linearTrackColor: palette.fillStrong,
        circularTrackColor: palette.fillStrong,
      ),
    );
  }

  static OutlineInputBorder _fieldBorder({Color color = Colors.transparent}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
      borderSide: BorderSide(color: color),
    );
  }
}
