import 'dart:async';

import 'package:a2ui_vgv_smart_home/l10n/l10n.dart';
import 'package:a2ui_vgv_smart_home/timeline/cubit/timeline_cubit.dart';
import 'package:a2ui_vgv_smart_home/timeline/day_phase.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// {@template timeline_rail}
/// The control that moves the demo's time, in the navigation panel.
///
/// One button per [DayPhase], stacked: the phase the time is in is filled, and
/// choosing another takes the time there, easing instead of jumping, see
/// [TimelineCubit]. Needs a [TimelineCubit] above it.
///
/// It sits in the rail on every window size, so the panel itself is only the
/// household's screen.
/// {@endtemplate}
class TimelineRail extends StatelessWidget {
  /// {@macro timeline_rail}
  const TimelineRail({super.key});

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

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: l10n.timelineLabel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.s1,
        children: [
          if (failed)
            Text(
              l10n.timelineFailed,
              textAlign: TextAlign.center,
              style: AppTypography.labelFor(
                context.colors,
              ).copyWith(color: context.colors.danger),
            ),
          for (final phase in DayPhase.values)
            _PhaseButton(
              phase: phase,
              label: labels[phase]!,
              selected: phase == selected,
              onPressed: press(phase),
            ),
        ],
      ),
    );
  }
}

/// One day phase button of the rail: its icon above its name.
class _PhaseButton extends StatelessWidget {
  const _PhaseButton({
    required this.phase,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final DayPhase phase;
  final String label;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final ink = selected
        ? context.colors.onAccent
        : onPressed == null
        ? context.colors.ink3
        : context.colors.ink;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 72,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: selected ? context.colors.ink : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 2,
            children: [
              Icon(phase.icon, size: 20, color: ink),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTypography.ui(
                  size: 12,
                  lineHeight: 16,
                  weight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
