import 'dart:async';
import 'dart:ui';

import 'package:a2ui_vgv_smart_home/l10n/l10n.dart';
import 'package:a2ui_vgv_smart_home/timeline/cubit/timeline_cubit.dart';
import 'package:a2ui_vgv_smart_home/timeline/day_phase.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// {@template timeline_bar}
/// The control that moves the demo's time, beside the tablet.
///
/// A frosted pill with a button for each [DayPhase]: morning, day, sunset and
/// evening. The one the time is in is filled, and choosing another takes the
/// time there, easing instead of jumping, see [TimelineCubit]. Needs a
/// [TimelineCubit] above it.
///
/// It lies flat below the tablet, and stands [vertical] to its right on a
/// phone's window.
/// {@endtemplate}
class TimelineBar extends StatelessWidget {
  /// {@macro timeline_bar}
  const TimelineBar({this.vertical = false, super.key});

  /// Whether the buttons stack, for the rail beside the tablet.
  final bool vertical;

  static const double _radius = 44;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TimelineCubit>().state;
    final l10n = context.l10n;
    final cubit = context.read<TimelineCubit>();
    final failed = state.status == TimelineStatus.failure;
    final canMove = state.status == TimelineStatus.ready && !state.moving;
    final selected = failed ? null : DayPhase.at(state.now);
    final labels = {
      DayPhase.morning: l10n.timelineMorning,
      DayPhase.day: l10n.timelineDay,
      DayPhase.sunset: l10n.timelineSunset,
      DayPhase.evening: l10n.timelineEvening,
    };
    // A clock that cannot be reached is asked again by any button.
    VoidCallback? press(DayPhase phase) {
      if (failed) return () => unawaited(cubit.reset());
      if (!canMove) return null;
      return () => unawaited(cubit.seekTo(phase.on(state.start)));
    }

    // The bar sits above the navigator, so it brings its own Material.
    return Material(
      type: MaterialType.transparency,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: l10n.timelineLabel,
        child: Padding(
          padding: vertical
              ? const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s1,
                  vertical: AppSpacing.s1,
                )
              : const EdgeInsets.fromLTRB(
                  AppSpacing.s4,
                  AppSpacing.s1,
                  AppSpacing.s4,
                  AppSpacing.s2,
                ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.s1,
            children: [
              if (failed)
                Text(
                  l10n.timelineFailed,
                  textAlign: TextAlign.center,
                  style: AppTypography.labelStrong.copyWith(
                    color: context.colors.danger,
                  ),
                ),
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_radius),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x2E030F30),
                      blurRadius: 48,
                      offset: Offset(0, 16),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_radius),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: context.colors.surfaceRaised.withValues(
                          alpha: 0.74,
                        ),
                        borderRadius: BorderRadius.circular(_radius),
                        border: Border.all(
                          color: context.colors.surfaceRaised.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        // Shrinks to fit a window too narrow or too short for
                        // the buttons.
                        child: FittedBox(
                          child: vertical
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 2,
                                  children: [
                                    for (final phase in DayPhase.values)
                                      _PhaseButton(
                                        phase: phase,
                                        label: labels[phase]!,
                                        selected: phase == selected,
                                        onPressed: press(phase),
                                        vertical: true,
                                      ),
                                  ],
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 4,
                                  children: [
                                    for (final phase in DayPhase.values)
                                      _PhaseButton(
                                        phase: phase,
                                        label: labels[phase]!,
                                        selected: phase == selected,
                                        onPressed: press(phase),
                                      ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One day phase button of the timeline bar.
class _PhaseButton extends StatelessWidget {
  const _PhaseButton({
    required this.phase,
    required this.label,
    required this.selected,
    required this.onPressed,
    this.vertical = false,
  });

  final DayPhase phase;
  final String label;
  final bool selected;
  final VoidCallback? onPressed;

  /// Whether the icon sits above the label, in the rail.
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: selected
            ? context.colors.onAccent
            : context.colors.ink,
        backgroundColor: selected ? context.colors.ink : Colors.transparent,
        disabledForegroundColor: selected
            ? context.colors.onAccent
            : context.colors.fillStrong,
        disabledBackgroundColor: selected ? context.colors.ink : null,
        minimumSize: Size(0, vertical ? 54 : 56),
        padding: vertical
            ? const EdgeInsets.symmetric(horizontal: 12)
            : const EdgeInsets.symmetric(horizontal: 22),
        iconSize: 22,
        shape: const StadiumBorder(),
        textStyle: AppTypography.ui(
          size: vertical ? 13 : 18,
          lineHeight: vertical ? 16 : 24,
          weight: FontWeight.w500,
          letterSpacing: vertical ? 0 : -0.18,
        ),
      ),
      child: vertical
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(phase.icon, size: 22),
                const SizedBox(height: 2),
                Text(label),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(phase.icon, size: 22),
                const SizedBox(width: 8),
                Text(label),
              ],
            ),
    );
  }
}
