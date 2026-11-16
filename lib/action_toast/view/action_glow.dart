import 'package:a2ui_vgv_smart_home/action_toast/cubit/action_toast_cubit.dart';
import 'package:app_ui/app_ui.dart';
import 'package:material_ui/material_ui.dart';

/// {@template action_glow}
/// The light that follows a request across the panel, behind the toast.
///
/// While the request is on its way it is a small, faint yellow glow rising from
/// the toast. On success it turns green and grows to wash over the panel, and
/// when the toast leaves it fades away in the color it had. A failure does the
/// same in coral. It never takes a tap.
/// {@endtemplate}
class ActionGlow extends StatefulWidget {
  /// {@macro action_glow}
  const ActionGlow({required this.status, super.key});

  /// Where the request the glow follows stands.
  final ActionToastStatus status;

  @override
  State<ActionGlow> createState() => _ActionGlowState();
}

/// Keeps the glow's color while it fades out.
class _ActionGlowState extends State<ActionGlow> {
  /// What the glow looks like while it is showing. Kept when the toast goes
  /// idle so the glow fades out in the color it had instead of changing.
  late _GlowKind _glow = _glowOf(widget.status) ?? _GlowKind.loading;

  static _GlowKind? _glowOf(ActionToastStatus status) => switch (status) {
    ActionToastStatus.loading => _GlowKind.loading,
    ActionToastStatus.success => _GlowKind.success,
    ActionToastStatus.error => _GlowKind.error,
    ActionToastStatus.idle => null,
  };

  @override
  void didUpdateWidget(ActionGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    _glow = _glowOf(widget.status) ?? _glow;
  }

  @override
  Widget build(BuildContext context) {
    final visible = widget.status != ActionToastStatus.idle;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final alpha = visible ? _glow.alpha : 0.0;
    final color = _glow.color(context.colors);
    return IgnorePointer(
      child: AnimatedContainer(
        duration: reduceMotion
            ? Duration.zero
            : Duration(milliseconds: visible ? 600 : 500),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.bottomCenter,
            radius: _glow.radius,
            colors: [
              color.withValues(alpha: alpha),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

/// How the glow looks: its color, opacity and radius.
///
/// The kind picks its color from the palette, so the glow follows the theme.
/// {@template glow_kind}
/// One of the three glows the toast shows.
/// {@endtemplate}
enum _GlowKind {
  loading(alpha: 0.22, radius: 0.55),
  success(alpha: 0.4, radius: 1.5),
  error(alpha: 0.35, radius: 1.3);

  const _GlowKind({required this.alpha, required this.radius});

  final double alpha;

  /// Relative to the shorter side of the panel.
  final double radius;

  Color color(AppPalette palette) => switch (this) {
    loading => palette.warning,
    success => palette.successLight,
    error => palette.danger,
  };
}
