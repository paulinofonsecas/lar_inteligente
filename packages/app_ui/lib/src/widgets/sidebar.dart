import 'package:app_ui/src/theme/app_palette.dart';
import 'package:app_ui/src/theme/app_typography.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// {@template sidebar_profile}
/// Someone the [Sidebar] can switch to.
/// {@endtemplate}
class SidebarProfile {
  /// {@macro sidebar_profile}
  const SidebarProfile({required this.name, this.photo});

  /// The profile name, whose initial the avatar shows without a [photo].
  final String name;

  /// Shown in the avatar. Without one the avatar shows the initial.
  final ImageProvider? photo;
}

/// {@template sidebar}
/// The rail down the left of the screen: who is looking, and where to go.
///
/// The profiles switch the dashboard; the lightbulb opens the tips sheet, the
/// [timeControl] moves the demo's clock and the settings reopen the key dialog.
/// {@endtemplate}
class Sidebar extends StatelessWidget {
  /// {@macro sidebar}
  const Sidebar({
    required this.profiles,
    required this.selectedIndex,
    required this.onProfileSelected,
    required this.onTips,
    required this.tipsTooltip,
    required this.onSettings,
    required this.settingsTooltip,
    this.timeControl,
    this.onTheme,
    this.themeTooltip = '',
    super.key,
  });

  /// The people the rail can switch between.
  final List<SidebarProfile> profiles;

  /// The index in [profiles] of the profile that is looking.
  final int selectedIndex;

  /// Called with the index of the profile that was tapped.
  final ValueChanged<int> onProfileSelected;

  /// Called when the tips button is pressed.
  final VoidCallback onTips;

  /// The tooltip and label of the tips button.
  final String tipsTooltip;

  /// Called when the settings button is pressed.
  final VoidCallback onSettings;

  /// The tooltip and label of the settings button.
  final String settingsTooltip;

  /// The app's own control above the bottom buttons, the demo's clock. The rail
  /// only leaves it room; whether it is a clock, a timer or nothing is the
  /// caller's business.
  final Widget? timeControl;

  /// Called when the appearance button is pressed. Hidden when null.
  final VoidCallback? onTheme;

  /// The tooltip of the appearance button.
  final String themeTooltip;

  /// The width of the rail.
  static const double width = 88;
  static const double _tileWidth = 72;
  static const double _tileHeight = 96;
  static const double _gap = 8;
  static const double _buttonSize = 64;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceRaised,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.colors.line),
        boxShadow: context.colors.shadows.soft,
      ),
      child: SizedBox(
        width: width,
        // Never scrolls: on a short screen the bottom is clipped, not scrolled.
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(
            context,
          ).copyWith(scrollbars: false),
          child: CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: (width - _tileWidth) / 2,
                    vertical: _gap,
                  ),
                  child: Column(
                    spacing: _gap,
                    children: [
                      _Profiles(
                        profiles: profiles,
                        selectedIndex: selectedIndex,
                        onSelected: onProfileSelected,
                      ),
                      const SizedBox(
                        width: 40,
                        child: Divider(height: 1, thickness: 1),
                      ),
                      const _NavButton(
                        icon: Symbols.home_rounded,
                        selected: true,
                        tooltip: 'Início',
                      ),
                      _NavButton(
                        icon: Symbols.lightbulb_rounded,
                        tooltip: tipsTooltip,
                        onPressed: onTips,
                      ),
                      const Spacer(),
                      ?timeControl,
                      if (onTheme != null)
                        _NavButton(
                          icon: Symbols.dark_mode_rounded,
                          tooltip: themeTooltip,
                          onPressed: onTheme,
                        ),
                      _NavButton(
                        icon: Symbols.settings_rounded,
                        tooltip: settingsTooltip,
                        onPressed: onSettings,
                      ),
                    ],
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

/// The profile tiles, with a highlight that slides to the selected one.
class _Profiles extends StatelessWidget {
  const _Profiles({
    required this.profiles,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<SidebarProfile> profiles;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const double _step = Sidebar._tileHeight + Sidebar._gap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Sidebar._tileWidth,
      height: profiles.length * _step - Sidebar._gap,
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeInOutCubicEmphasized,
            top: selectedIndex * _step,
            width: Sidebar._tileWidth,
            height: Sidebar._tileHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHigh,
                borderRadius: const BorderRadius.all(Radius.circular(999)),
              ),
            ),
          ),
          for (final (index, profile) in profiles.indexed)
            Positioned(
              top: index * _step,
              width: Sidebar._tileWidth,
              height: Sidebar._tileHeight,
              child: _ProfileTile(
                profile: profile,
                selected: index == selectedIndex,
                onTap: () => onSelected(index),
              ),
            ),
        ],
      ),
    );
  }
}

/// One selectable profile of the sidebar.
class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.profile,
    required this.selected,
    required this.onTap,
  });

  final SidebarProfile profile;
  final bool selected;
  final VoidCallback onTap;

  static const _duration = Duration(milliseconds: 350);
  static const Curve _curve = Curves.easeInOutCubic;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: profile.name,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        // The border is the highlight's own color, so it vanishes on the
        // selected tile without being animated.
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: context.colors.line, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 6,
            children: [
              AnimatedOpacity(
                duration: _duration,
                curve: _curve,
                opacity: selected ? 1 : 0.8,
                child: _Avatar(profile: profile),
              ),
              AnimatedDefaultTextStyle(
                duration: _duration,
                curve: _curve,
                style: AppTypography.ui(
                  size: 15,
                  lineHeight: 20,
                  letterSpacing: -0.07,
                  weight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? context.colors.ink : context.colors.ink3,
                ),
                child: Text(
                  profile.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The round photo of a profile.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.profile});

  final SidebarProfile profile;

  @override
  Widget build(BuildContext context) {
    final photo = profile.photo;
    return CircleAvatar(
      radius: 24,
      backgroundColor: context.colors.accentSoft,
      foregroundImage: photo,
      child: Text(
        profile.name.characters.first,
        style: AppTypography.titleSmall.copyWith(color: context.colors.accent),
      ),
    );
  }
}

/// A round navigation button of the sidebar.
class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    this.selected = false,
    this.tooltip,
    this.onPressed,
  });

  final IconData icon;
  final bool selected;
  final String? tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? context.colors.ink : Colors.transparent,
          ),
          child: SizedBox.square(
            dimension: Sidebar._buttonSize,
            child: Icon(
              icon,
              size: 28,
              color: selected ? context.colors.onPrimary : context.colors.ink3,
            ),
          ),
        ),
      ),
    );
  }
}
