import 'package:material_ui/material_ui.dart';

/// {@template app_shadow_set}
/// The elevation tokens of one theme: small controls, floating panels and
/// cards.
///
/// A shadow lifts a surface by darkening what is around it, which a dark theme
/// cannot do: with nothing darker than the background, the same shadow would
/// vanish. The dark set is therefore heavier and tighter, and the panels lean
/// on their hairline instead.
/// {@endtemplate}
class AppShadowSet {
  /// {@macro app_shadow_set}
  const AppShadowSet({
    required this.small,
    required this.soft,
    required this.card,
  });

  /// Blends every shadow towards the other set, so a theme switch can animate.
  AppShadowSet.lerp(AppShadowSet a, AppShadowSet b, double t)
    : small = _mixShadows(a.small, b.small, t),
      soft = _mixShadows(a.soft, b.soft, t),
      card = _mixShadows(a.card, b.card, t);

  /// Small controls.
  final List<BoxShadow> small;

  /// The floating panels around the dashboard: sidebar, ask bar, cards.
  final List<BoxShadow> soft;

  /// Cards and surfaces.
  final List<BoxShadow> card;

  /// The light panel's elevation.
  static const light = AppShadowSet(
    small: AppShadows.small,
    soft: AppShadows.soft,
    card: AppShadows.card,
  );

  /// The dark panel's elevation.
  static const dark = AppShadowSet(
    small: [
      BoxShadow(
        color: Color(0x4D000000),
        blurRadius: 6,
        offset: Offset(0, 2),
      ),
    ],
    soft: [
      BoxShadow(
        color: Color(0x80000000),
        blurRadius: 40,
        offset: Offset(0, 12),
      ),
    ],
    card: [
      BoxShadow(
        color: Color(0x66000000),
        blurRadius: 3,
        offset: Offset(0, 1),
      ),
      BoxShadow(
        color: Color(0x99000000),
        blurRadius: 26,
        spreadRadius: -10,
        offset: Offset(0, 10),
      ),
    ],
  );
}

List<BoxShadow> _mixShadows(
  List<BoxShadow> from,
  List<BoxShadow> to,
  double t,
) => [
  for (var i = 0; i < from.length && i < to.length; i++)
    BoxShadow.lerp(from[i], to[i], t)!,
];

/// {@template app_shadows}
/// The elevation tokens of the light panel: small controls, floating panels and
/// cards.
///
/// Kept as the light values so the widgets that predate [AppShadowSet] keep
/// working; new code reads `context.colors.shadows`.
/// {@endtemplate}
abstract final class AppShadows {
  /// Small controls.
  static const small = [
    BoxShadow(color: Color(0x1A101828), blurRadius: 4, offset: Offset(0, 1)),
  ];

  /// The floating panels around the dashboard: sidebar, ask bar, cards.
  static const soft = [
    BoxShadow(color: Color(0x0D1C1A14), blurRadius: 40, offset: Offset(0, 12)),
  ];

  /// Cards and surfaces.
  static const card = [
    BoxShadow(color: Color(0x0D101828), blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(
      color: Color(0x29141E3C),
      blurRadius: 26,
      spreadRadius: -10,
      offset: Offset(0, 10),
    ),
  ];
}
