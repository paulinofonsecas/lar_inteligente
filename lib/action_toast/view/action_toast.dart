import 'dart:math' as math;

import 'package:a2ui_vgv_smart_home/action_toast/cubit/action_toast_cubit.dart';
import 'package:a2ui_vgv_smart_home/action_toast/view/action_glow.dart';
import 'package:a2ui_vgv_smart_home/l10n/l10n.dart';
import 'package:a2ui_vgv_smart_home/voice/view/cancel_pill.dart';
import 'package:app_ui/app_ui.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// {@template action_toast}
/// The request on its way, shown at the bottom of the screen: a sparkle, the
/// label and, for a spoken command, a way out.
///
/// On success the sparkle turns into a green check that scales in and the label
/// becomes "Completed". On failure it turns into a coral cross, the pill shakes
/// once and a line says why. The light behind the pill is [ActionGlow]. The
/// dashboard behind it stays usable.
/// {@endtemplate}
class ActionToast extends StatefulWidget {
  /// {@macro action_toast}
  const ActionToast({required this.state, required this.onCancel, super.key});

  /// What to show. Never [ActionToastStatus.idle]: an idle toast is not built.
  /// What the toast shows.
  final ActionToastState state;

  /// Called when the user takes the request back.
  final VoidCallback onCancel;

  @override
  State<ActionToast> createState() => _ActionToastState();
}

/// Drives the shake and the spinning border of the toast.
class _ActionToastState extends State<ActionToast>
    with TickerProviderStateMixin {
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  /// Turns the gradient on the border around while the request is on its way.
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  /// The soft lift under the pill (`0 4 8 rgba(2, 15, 48, 0.03)`).
  static const _shadow = [
    BoxShadow(color: Color(0x08020F30), blurRadius: 8, offset: Offset(0, 4)),
  ];

  ActionToastStatus get _status => widget.state.status;

  @override
  void initState() {
    super.initState();
    _enter();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncSpin();
  }

  @override
  void didUpdateWidget(ActionToast oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.status != _status) {
      _enter();
      _syncSpin();
    }
  }

  void _syncSpin() {
    final spinning =
        _status == ActionToastStatus.loading &&
        !MediaQuery.disableAnimationsOf(context);
    if (spinning) {
      if (!_spin.isAnimating) _spin.repeat();
    } else {
      _spin.stop();
    }
  }

  void _enter() {
    if (_status == ActionToastStatus.error) {
      _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final reason = state.status == ActionToastStatus.error
        ? state.reason ?? context.l10n.actionFailed
        : null;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720),
      child: AnimatedBuilder(
        animation: _shake,
        builder: (context, child) => Transform.translate(
          offset: Offset(
            reduceMotion
                ? 0
                : math.sin(_shake.value * math.pi * 4) *
                      10 *
                      (1 - _shake.value),
            0,
          ),
          child: CustomPaint(
            foregroundPainter: _ProgressBorder(
              progress: _spin,
              active: state.status == ActionToastStatus.loading,
              spark: context.colors.spark,
              warning: context.colors.warning,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: state.status == ActionToastStatus.error
                      ? context.colors.danger
                      : context.colors.overlayOnTintStrong,
                ),
                boxShadow: _shadow,
                color: context.colors.surfaceRaised,
              ),
              child: child,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            8,
            state.cancellable && state.status == ActionToastStatus.loading
                ? 8
                : 24,
            8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              _Indicator(status: state.status, reduceMotion: reduceMotion),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.status == ActionToastStatus.success
                          ? context.l10n.actionCompleted
                          : state.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyLarge.copyWith(
                        color: state.status == ActionToastStatus.success
                            ? context.colors.success
                            : context.colors.ink,
                      ),
                    ),
                    if (reason != null)
                      Text(
                        reason,
                        key: const ValueKey('reason'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.colors.ink2,
                        ),
                      ),
                  ],
                ),
              ),
              if (state.cancellable &&
                  state.status == ActionToastStatus.loading)
                CancelPill(onPressed: widget.onCancel)
              else
                const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

/// The sparkle, and what it turns into.
class _Indicator extends StatelessWidget {
  const _Indicator({required this.status, required this.reduceMotion});

  final ActionToastStatus status;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 350);
    return SizedBox.square(
      dimension: 24,
      child: AnimatedSwitcher(
        duration: duration,
        switchInCurve: Curves.elasticOut,
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: switch (status) {
          ActionToastStatus.success => Icon(
            Symbols.check_circle_rounded,
            key: const ValueKey('success'),
            color: context.colors.successLight,
            fill: 1,
            size: 24,
          ),
          ActionToastStatus.error => Icon(
            Symbols.cancel_rounded,
            key: const ValueKey('error'),
            color: context.colors.danger,
            fill: 1,
            size: 24,
          ),
          ActionToastStatus.idle || ActionToastStatus.loading => Icon(
            Symbols.auto_awesome_rounded,
            key: const ValueKey('loading'),
            color: context.colors.ink,
            fill: 1,
            size: 24,
          ),
        },
      ),
    );
  }
}

/// A bright arc that runs around the border of the pill while the request is
/// on its way, so the toast shows it is making progress.
class _ProgressBorder extends CustomPainter {
  _ProgressBorder({
    required this.progress,
    required this.active,
    required this.spark,
    required this.warning,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final bool active;
  final Color spark;
  final Color warning;

  static const double _width = 2.5;

  @override
  void paint(Canvas canvas, Size size) {
    if (!active) return;
    final rect = Offset.zero & size;
    final shader = SweepGradient(
      transform: GradientRotation(progress.value * 2 * math.pi),
      colors: [
        spark.withValues(alpha: 0),
        spark.withValues(alpha: 0),
        warning,
        spark,
      ],
      stops: const [0, 0.45, 0.8, 1],
    ).createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.deflate(_width / 2),
        Radius.circular(size.height / 2),
      ),
      Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = _width,
    );
  }

  @override
  bool shouldRepaint(_ProgressBorder oldDelegate) =>
      oldDelegate.active != active;
}
