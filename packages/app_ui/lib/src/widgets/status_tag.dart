import 'package:app_ui/src/theme/app_icons.dart';
import 'package:app_ui/src/theme/app_palette.dart';
import 'package:app_ui/src/theme/app_spacing.dart';
import 'package:app_ui/src/theme/app_tone.dart';
import 'package:app_ui/src/theme/app_typography.dart';
import 'package:material_ui/material_ui.dart';

/// {@template status_tag_kind}
/// How a [StatusTag] reads: what it says about the card.
/// {@endtemplate}
enum StatusTagKind {
  /// "Updated", "Updated just now".
  updated('sparkle'),

  /// "New".
  isNew('sparkle'),

  /// "Moved".
  moved('clock'),

  /// Any other short fact: "Now 4:30", "6 guests", "On".
  info(null);

  /// {@macro status_tag_kind}
  const StatusTagKind(this.defaultIcon);

  /// The icon used when the tag names none.
  final String? defaultIcon;

  /// The kind the catalog calls [name]; unknown names read as [info].
  static StatusTagKind byName(String? name) => switch (name) {
    'updated' => updated,
    'new' => isNew,
    'moved' => moved,
    _ => info,
  };
}

/// {@template status_tag_fill}
/// What fills a [StatusTag]. Each one is a palette role, so the tag follows
/// the theme instead of carrying a hex.
/// {@endtemplate}
enum StatusTagFill {
  /// The warm fill of pills that sit on a card.
  warm,

  /// The heavier surface fill, for a tag that reports a change.
  surfaceHigh,

  /// The veil over a tinted card, for a tag inside one.
  overlay,

  /// The wash of the tag's tone, for a tag about that tone.
  tone,
}

/// {@template status_tag}
/// The small pill in a card corner that says the card changed.
/// {@endtemplate}
class StatusTag extends StatelessWidget {
  /// {@macro status_tag}
  const StatusTag({
    required this.label,
    this.kind = StatusTagKind.info,
    this.icon,
    this.fill = StatusTagFill.warm,
    this.tone = AppTone.neutral,
    this.tint,
    this.dot,
    this.sparkDot = false,
    this.inkDot = false,
    this.mutedInk = false,
    this.ink,
    super.key,
  });

  /// The pill text.
  final String label;

  /// The pill fill, which is a palette role.
  final StatusTagFill fill;

  /// The card's tone, whose ink [StatusTagFill.tone] paints.
  final AppTone tone;

  /// The pill fill, for a caller that already has a color. Wins over [fill].
  final Color? tint;

  /// A small filled dot before the label, in place of the icon.
  final Color? dot;

  /// Draws [dot] in the palette's spark, for the assistant's own tags.
  final bool sparkDot;

  /// Draws [dot] in the palette's ink, for a tag that marks a change.
  final bool inkDot;

  /// Draws the label in the secondary ink, for a tag that is a subtitle.
  final bool mutedInk;

  /// Overrides the text and icon color.
  final Color? ink;

  /// How the tag reads, which picks its default icon.
  final StatusTagKind kind;

  /// An icon name from [AppIcons]; defaults from [kind].
  final String? icon;

  static const double _height = AppSpacing.chipHeight;

  @override
  Widget build(BuildContext context) {
    final iconName = icon ?? kind.defaultIcon;
    final colors = context.colors;
    final toneColors = colors.tone(tone);
    final fill =
        tint ??
        switch (this.fill) {
          StatusTagFill.warm => colors.fillWarm,
          StatusTagFill.surfaceHigh => colors.surfaceContainerHigh,
          StatusTagFill.overlay => colors.overlayOnTintStrong,
          StatusTagFill.tone => toneColors.wash ?? colors.fillWarm,
        };
    final ink =
        this.ink ??
        switch (this.fill) {
          StatusTagFill.tone => toneColors.ink,
          StatusTagFill.overlay when tone != AppTone.neutral => toneColors.ink,
          _ => mutedInk ? colors.ink2 : colors.ink,
        };
    final dot = sparkDot
        ? colors.spark
        : inkDot
        ? colors.ink
        : this.dot;
    return Container(
      height: _height,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.chipPadding),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot != null) ...[
            Container(
              width: AppSpacing.s2,
              height: AppSpacing.s2,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ] else if (iconName != null) ...[
            Icon(AppIcons.byName(iconName), size: 18, color: ink),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelMedium.copyWith(color: ink),
            ),
          ),
        ],
      ),
    );
  }
}
