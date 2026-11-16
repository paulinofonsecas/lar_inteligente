import 'package:app_ui/src/theme/app_palette.dart';
import 'package:app_ui/src/theme/app_typography.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// {@template brand_lockup}
/// The app's lockup: the house glyph with "Lar Inteligente" beside it.
///
/// Drawn in Flutter, in its own colours, so [semanticLabel] says it to
/// assistive tech.
/// {@endtemplate}
class BrandLockup extends StatelessWidget {
  /// {@macro brand_lockup}
  const BrandLockup({required this.semanticLabel, super.key});

  /// What a screen reader announces, for example `Lar Inteligente`.
  final String semanticLabel;

  static const double _width = 305;
  static const double _height = 57;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      container: true,
      child: ExcludeSemantics(
        child: SizedBox(
          width: _width,
          height: _height,
          child: Row(
            children: [
              Icon(
                Symbols.house_rounded,
                size: 38,
                color: context.colors.onPrimary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Lar Inteligente',
                    style: AppTypography.ui(
                      size: 28,
                      lineHeight: 32,
                      weight: FontWeight.w600,
                      letterSpacing: -0.5,
                      color: context.colors.onPrimary,
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
