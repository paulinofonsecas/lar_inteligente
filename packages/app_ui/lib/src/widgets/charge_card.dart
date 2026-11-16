import 'package:app_ui/src/theme/app_icons.dart';
import 'package:app_ui/src/theme/app_palette.dart';
import 'package:app_ui/src/theme/app_spacing.dart';
import 'package:app_ui/src/theme/app_tone.dart';
import 'package:app_ui/src/theme/app_typography.dart';
import 'package:app_ui/src/widgets/glow_surface.dart';
import 'package:app_ui/src/widgets/status_tag.dart';
import 'package:material_ui/material_ui.dart';

/// {@template charge_card}
/// Battery, range and charging window for a car.
/// {@endtemplate}
class ChargeCard extends StatelessWidget {
  /// {@macro charge_card}
  const ChargeCard({
    required this.percent,
    this.title = 'Carro',
    this.status,
    this.range,
    this.summary,
    this.window,
    this.windowIcon = 'clock',
    this.tag,
    this.tagKind = StatusTagKind.info,
    this.tagIcon,
    super.key,
  });

  /// The card heading.
  final String title;

  /// Appended after the title, for example `Plugged in`.
  final String? status;

  /// Battery level, 0 to 100.
  final int percent;

  /// The estimated range, for example `190 mi`.
  final String? range;

  /// A one line verdict, for example `Enough for both stops`.
  final String? summary;

  /// The footer text, for example `Charging tonight 9 PM - 6 AM`.
  final String? window;

  /// The footer icon name: `clock` for a window, `savings` for a saving.
  final String windowIcon;

  /// {@template card_tag_text}
  /// The text of the corner [StatusTag], or null for none.
  /// {@endtemplate}
  final String? tag;

  /// How the corner tag reads.
  final StatusTagKind tagKind;

  /// An icon name from `AppIcons` for the corner tag; defaults from
  /// [tagKind].
  final String? tagIcon;

  /// Under this level the bar turns warm.
  static const lowLevel = 30;

  /// The height of the battery track.
  static const double _barHeight = 20;

  @override
  Widget build(BuildContext context) {
    const tone = AppTone.energy;
    final level = percent.clamp(0, 100);
    final status = this.status;
    final range = this.range;
    final summary = this.summary;
    final window = this.window;
    final tag = this.tag;
    final colors = context.colors;
    final toneColors = colors.tone(tone);
    final wash = toneColors.wash ?? colors.surfaceRaised;
    return GlowSurface(
      color: wash,
      glows: [
        Glow(
          left: -80,
          top: -120,
          size: 260,
          color: wash.withValues(alpha: 0.9),
        ),
        Glow(
          left: 146,
          top: 60,
          size: 360,
          color: toneColors.accent.withValues(alpha: 0.16),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.byName('car'),
                size: 26,
                color: context.colors.tone(tone).ink,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  status == null ? title : '$title · $status',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleSmall.copyWith(
                    color: context.colors.tone(tone).ink,
                  ),
                ),
              ),
              if (tag != null) ...[
                const SizedBox(width: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: StatusTag(
                    label: tag,
                    kind: tagKind,
                    icon: tagIcon,
                    tint: context.colors.overlayOnTint,
                    ink: context.colors.tone(tone).ink,
                  ),
                ),
              ],
            ],
          ),
          Row(
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '$level%',
                    maxLines: 1,
                    style: AppTypography.displayLarge.copyWith(
                      color: context.colors.tone(tone).ink,
                      height: 1,
                    ),
                  ),
                ),
              ),
              if (range != null || summary != null) ...[
                const SizedBox(width: AppSpacing.s4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (range != null)
                        Text(
                          range,
                          style: AppTypography.titleSmall.copyWith(
                            color: context.colors.tone(tone).ink,
                          ),
                        ),
                      if (summary != null)
                        Text(
                          summary,
                          style: AppTypography.bodyMedium.copyWith(
                            color: context.colors
                                .tone(tone)
                                .ink
                                .withValues(alpha: 0.78),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
                child: LinearProgressIndicator(
                  value: level / 100,
                  minHeight: _barHeight,
                  color: level < lowLevel
                      ? context.colors.danger
                      : context.colors.tone(tone).ink,
                  backgroundColor: context.colors.overlayOnTint,
                ),
              ),
              if (window != null) ...[
                const SizedBox(height: AppSpacing.s3),
                Row(
                  children: [
                    Icon(
                      AppIcons.byName(windowIcon),
                      size: 20,
                      color: context.colors.tone(tone).ink,
                    ),
                    const SizedBox(width: AppSpacing.s2),
                    Expanded(
                      child: Text(
                        window,
                        style: AppTypography.labelMedium.copyWith(
                          color: context.colors.tone(tone).ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
