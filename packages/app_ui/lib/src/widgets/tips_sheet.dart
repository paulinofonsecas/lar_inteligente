import 'package:app_ui/src/theme/app_colors.dart';
import 'package:app_ui/src/theme/app_spacing.dart';
import 'package:app_ui/src/theme/app_typography.dart';
import 'package:app_ui/src/widgets/action_pill.dart';
import 'package:app_ui/src/widgets/card_icon_bubble.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// {@template tips_sheet_item}
/// One suggestion of [TipsSheet]: what it is, what it does, and the request
/// trying it sends.
/// {@endtemplate}
class TipsSheetItem {
  /// {@macro tips_sheet_item}
  const TipsSheetItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.ask,
  });

  /// The icon leading the suggestion.
  final IconData icon;

  /// The suggestion's name.
  final String title;

  /// One line on what the suggestion does.
  final String description;

  /// The text trying it sends, exactly as the person had typed it.
  final String ask;
}

/// {@template tips_sheet}
/// The "Sugestões" sheet, in the style of the phone's Tips app: a curated
/// list of what the panel can do, each with a try-it button that sends the
/// item's [TipsSheetItem.ask].
/// {@endtemplate}
class TipsSheet extends StatelessWidget {
  /// {@macro tips_sheet}
  const TipsSheet({
    required this.title,
    required this.subtitle,
    required this.tryLabel,
    required this.items,
    required this.onTry,
    super.key,
  });

  /// The sheet's heading.
  final String title;

  /// One line under the heading.
  final String subtitle;

  /// The label of every try-it button.
  final String tryLabel;

  /// The suggestions, in the order they are shown.
  final List<TipsSheetItem> items;

  /// Called with the item whose try-it button was pressed.
  final ValueChanged<TipsSheetItem> onTry;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.s2),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.fillStrong,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const SizedBox(width: 48, height: 4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              AppSpacing.s3,
              AppSpacing.s2,
              0,
            ),
            child: Row(
              children: [
                const CardIconBubble(
                  icon: Symbols.lightbulb_rounded,
                  background: AppColors.warningSoft,
                ),
                const SizedBox(width: AppSpacing.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTypography.titleSmall),
                      Text(subtitle, style: AppTypography.label),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Symbols.close_rounded, size: 24),
                  tooltip: MaterialLocalizations.of(
                    context,
                  ).closeButtonTooltip,
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.s3,
                AppSpacing.gutter,
                AppSpacing.gutter,
              ),
              children: [
                for (final (index, item) in items.indexed) ...[
                  if (index > 0) const SizedBox(height: AppSpacing.s3),
                  _TipTile(
                    item: item,
                    tryLabel: tryLabel,
                    onTry: () => onTry(item),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One row of the sheet: the suggestion and its try-it button.
class _TipTile extends StatelessWidget {
  const _TipTile({
    required this.item,
    required this.tryLabel,
    required this.onTry,
  });

  final TipsSheetItem item;
  final String tryLabel;
  final VoidCallback onTry;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.innerPanelRadius),
        border: Border.all(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s4),
        child: Row(
          children: [
            CardIconBubble(icon: item.icon),
            const SizedBox(width: AppSpacing.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(item.title, style: AppTypography.labelLarge),
                  Text(item.description, style: AppTypography.label),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s3),
            ActionPill(
              label: tryLabel,
              onPressed: onTry,
              icon: 'spark',
              horizontalPadding: 18,
            ),
          ],
        ),
      ),
    );
  }
}
