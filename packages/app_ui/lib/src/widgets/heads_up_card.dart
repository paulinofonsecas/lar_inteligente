import 'package:app_ui/src/theme/app_palette.dart';
import 'package:app_ui/src/theme/app_spacing.dart';
import 'package:app_ui/src/theme/app_tone.dart';
import 'package:app_ui/src/theme/app_typography.dart';
import 'package:app_ui/src/widgets/action_pill.dart';
import 'package:app_ui/src/widgets/glow_surface.dart';
import 'package:material_ui/material_ui.dart';

/// {@template heads_up_variant}
/// How urgent a [HeadsUpCard] is.
/// {@endtemplate}
enum HeadsUpVariant {
  /// Something to know about soon: an amber wash and a live dot.
  headsUp,

  /// Something to act on now: a red wash and border.
  urgent;

  /// The variant the catalog calls [name]; unknown names read as [headsUp].
  static HeadsUpVariant byName(String? name) =>
      name == 'urgent' ? urgent : headsUp;
}

/// {@template heads_up_action_data}
/// One button on a [HeadsUpCard].
/// {@endtemplate}
class HeadsUpActionData {
  /// {@macro heads_up_action_data}
  const HeadsUpActionData({
    required this.label,
    this.icon,
    this.isPrimary = false,
    this.isDone = false,
    this.onPressed,
  });

  /// The pill text. A done action reads in the past tense: "Blinds closed".
  final String label;

  /// An icon name from `AppIcons`.
  final String? icon;

  /// Draws the button as the recommended one.
  final bool isPrimary;

  /// The server finished the action: green wash, check, no press.
  final bool isDone;

  /// Called when the button is pressed. Null disables it.
  final VoidCallback? onPressed;
}

/// {@template heads_up_card}
/// A timely item the agent surfaces unprompted, with a reason line and one or
/// two things to do about it.
///
/// [HeadsUpVariant.headsUp] is amber, [HeadsUpVariant.urgent] is red. The top
/// line, the text and the actions spread over the card's height, so the
/// actions sit at the bottom and no space is left empty below them.
/// {@endtemplate}
class HeadsUpCard extends StatelessWidget {
  /// {@macro heads_up_card}
  const HeadsUpCard({
    required this.title,
    this.message,
    this.variant = HeadsUpVariant.headsUp,
    this.source,
    this.timestamp,
    this.actions = const [],
    super.key,
  });

  /// The headline.
  final String title;

  /// The reason line under the headline.
  final String? message;

  /// How urgent the card is, which picks its color.
  final HeadsUpVariant variant;

  /// Where the item comes from: "Weather".
  final String? source;

  /// When it happened: "1 min ago".
  final String? timestamp;

  /// The buttons, the first primary unless one says otherwise.
  final List<HeadsUpActionData> actions;

  bool get _urgent => variant == HeadsUpVariant.urgent;

  static const double _borderWidth = 2;

  /// Below this width two pills no longer fit on one line, and a second line
  /// would not fit the height, so only the primary action is shown.
  static const double _singleActionWidth = 560;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return LayoutBuilder(
      builder: (context, constraints) => _card(
        colors,
        singleAction:
            constraints.hasBoundedWidth &&
            constraints.maxWidth < _singleActionWidth,
      ),
    );
  }

  Widget _card(AppPalette colors, {required bool singleAction}) {
    final message = this.message;
    final primary = actions.any((action) => action.isPrimary)
        ? actions.indexWhere((action) => action.isPrimary)
        : 0;
    final shown = singleAction && actions.isNotEmpty
        ? [(primary, actions[primary])]
        : [for (var i = 0; i < actions.length; i++) (i, actions[i])];
    final lighting = colors.tone(AppTone.lighting);
    return GlowSurface(
      color: _urgent ? colors.dangerSoft : colors.surfaceRaised,
      border: BorderSide(
        color: _urgent ? colors.danger : colors.warning.withValues(alpha: 0.6),
        width: _borderWidth,
      ),
      glows: _urgent
          ? [
              Glow(
                left: -82,
                top: -122,
                size: 260,
                color: colors.danger.withValues(alpha: 0.12),
              ),
              Glow(
                left: 144,
                top: 58,
                size: 360,
                color: colors.danger.withValues(alpha: 0.3),
              ),
            ]
          : [
              Glow(
                left: -142,
                top: -182,
                size: 360,
                color: lighting.wash ?? colors.fillWarm,
              ),
            ],
      padding: _urgent
          ? const EdgeInsets.symmetric(
              horizontal: AppSpacing.cardPadding,
              vertical: AppSpacing.cardPaddingCompact,
            )
          : const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _eyebrow(colors),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: _urgent
                    ? AppTypography.titleSmall.copyWith(
                        color: colors.onErrorContainer,
                      )
                    : AppTypography.titleMedium,
              ),
              if (message != null) ...[
                SizedBox(height: _urgent ? AppSpacing.s1 : AppSpacing.s2),
                Text(
                  message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelFor(colors).copyWith(
                    color: _urgent
                        ? colors.onErrorContainer.withValues(alpha: 0.78)
                        : colors.ink2,
                  ),
                ),
              ],
            ],
          ),
          if (shown.isEmpty)
            const SizedBox.shrink()
          else
            Wrap(
              spacing: AppSpacing.s3,
              runSpacing: AppSpacing.s2,
              children: [
                for (final (i, action) in shown)
                  ActionPill(
                    label: action.label,
                    icon: action.icon,
                    onPressed: action.onPressed,
                    style: action.isDone
                        ? ActionPillStyle.done
                        : i == primary
                        ? ActionPillStyle.primary
                        : ActionPillStyle.secondary,
                  ),
              ],
            ),
        ],
      ),
    );
  }

  /// The live dot: a solid dot inside a ring of the same color.
  Widget _dot(double size, Color color) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Container(
        width: size / 2,
        height: size / 2,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  Widget _eyebrow(AppPalette colors) {
    final source = this.source;
    final timestamp = this.timestamp;
    if (_urgent) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Container(
              height: AppSpacing.chipHeight,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.chipPadding,
              ),
              decoration: BoxDecoration(
                color: colors.overlayOnTintStrong,
                borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dot(12, colors.danger),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      source == null ? 'Atenção' : 'Atenção · $source',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelMedium.copyWith(
                        color: colors.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (timestamp != null) ...[
            const SizedBox(width: AppSpacing.s2),
            Text(
              timestamp,
              style: AppTypography.labelMedium.copyWith(
                color: colors.onErrorContainer,
              ),
            ),
          ],
        ],
      );
    }
    return Row(
      children: [
        _dot(16, colors.ink),
        const SizedBox(width: AppSpacing.s2),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Atenção',
                  style: AppTypography.labelMediumEmphasized.copyWith(
                    color: colors.tone(AppTone.lighting).ink,
                  ),
                ),
                if (source != null) TextSpan(text: ' · $source'),
              ],
              style: AppTypography.labelFor(colors),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // The text takes the room, so the timestamp keeps to the right padding
        // of the card.
        if (timestamp != null) ...[
          const SizedBox(width: AppSpacing.s2),
          Text(timestamp, style: AppTypography.labelFor(colors)),
        ],
      ],
    );
  }
}
