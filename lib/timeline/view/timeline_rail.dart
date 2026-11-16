import 'dart:async';

import 'package:a2ui_vgv_smart_home/l10n/l10n.dart';
import 'package:a2ui_vgv_smart_home/timeline/cubit/timeline_cubit.dart';
import 'package:a2ui_vgv_smart_home/timeline/day_phase.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// {@template timeline_rail}
/// The control that moves the demo's time, in the panel's header.
///
/// One button per [DayPhase], side by side beside the brand: the phase the
/// time is in is filled, and choosing another takes the time there, easing
/// instead of jumping, see [TimelineCubit]. Needs a [TimelineCubit] above it.
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
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.s1,
          children: [
            if (failed)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.s2),
                child: Text(
                  l10n.timelineFailed,
                  style: AppTypography.labelFor(
                    context.colors,
                  ).copyWith(color: context.colors.danger),
                ),
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
      ),
    );
  }
}

/// One day phase button of the rail: its icon, and its name when it is the one
/// the time is in.
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
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: selected ? 14 : 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: selected ? context.colors.ink : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                Icon(phase.icon, size: 20, color: ink),
                if (selected)
                  Text(
                    label,
                    maxLines: 1,
                    style: AppTypography.ui(
                      size: 14,
                      lineHeight: 18,
                      weight: FontWeight.w600,
                      color: ink,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
