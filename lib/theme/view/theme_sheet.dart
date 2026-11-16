import 'package:a2ui_vgv_smart_home/l10n/l10n.dart';
import 'package:a2ui_vgv_smart_home/theme/cubit/theme_cubit.dart';
import 'package:a2ui_vgv_smart_home/theme/panel_theme.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// Opens the appearance sheet, where the panel is set to light, dark, or the
/// demo's time of day.
Future<void> showThemeSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => const ThemeSheet(),
  );
}

/// {@template theme_sheet}
/// The sheet [showThemeSheet] shows: one segment per theme mode.
/// {@endtemplate}
class ThemeSheet extends StatelessWidget {
  /// {@macro theme_sheet}
  const ThemeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mode = context.watch<ThemeCubit>().state;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceRaised,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.s5,
            AppSpacing.gutter,
            AppSpacing.s6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.s4,
            children: [
              Row(
                spacing: AppSpacing.s3,
                children: [
                  CardIconBubble(
                    icon: Symbols.dark_mode_rounded,
                    background: context.colors.accentSoft,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.themeTitle, style: AppTypography.titleSmall),
                        Text(
                          l10n.themeSubtitle,
                          style: AppTypography.labelFor(context.colors),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SegmentedButton<PanelTheme>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: PanelTheme.light,
                    icon: const Icon(Symbols.light_mode_rounded),
                    label: Text(l10n.themeLight),
                  ),
                  ButtonSegment(
                    value: PanelTheme.dark,
                    icon: const Icon(Symbols.dark_mode_rounded),
                    label: Text(l10n.themeDark),
                  ),
                  ButtonSegment(
                    value: PanelTheme.auto,
                    icon: const Icon(Symbols.brightness_auto_rounded),
                    label: Text(l10n.themeAuto),
                  ),
                ],
                selected: {mode},
                onSelectionChanged: (selection) =>
                    context.read<ThemeCubit>().select(selection.single),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
