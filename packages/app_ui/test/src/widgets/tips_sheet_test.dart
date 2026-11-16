import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../helpers/pump_component.dart';

const _items = [
  TipsSheetItem(
    icon: Symbols.mic_rounded,
    title: 'Fale com o painel',
    description: 'Toque no microfone e peça.',
    ask: 'preaqueça o forno',
  ),
  TipsSheetItem(
    icon: Symbols.undo_rounded,
    title: 'Desfazer com um toque',
    description: 'Toda mudança tem volta.',
    ask: 'desfazer a última mudança',
  ),
];

void main() {
  group(TipsSheet, () {
    testWidgets('shows the heading and every suggestion', (tester) async {
      await tester.pumpComponent(
        TipsSheet(
          title: 'Sugestões',
          subtitle: 'O que o painel faz',
          tryLabel: 'Experimentar',
          items: _items,
          onTry: (_) {},
        ),
      );

      expect(find.text('Sugestões'), findsOneWidget);
      expect(find.text('O que o painel faz'), findsOneWidget);
      for (final item in _items) {
        expect(find.text(item.title), findsOneWidget);
        expect(find.text(item.description), findsOneWidget);
        expect(find.byIcon(item.icon), findsOneWidget);
      }
      expect(find.text('Experimentar'), findsNWidgets(_items.length));
    });

    testWidgets('hands the suggestion that was tried to the caller', (
      tester,
    ) async {
      final tried = <TipsSheetItem>[];
      await tester.pumpComponent(
        TipsSheet(
          title: 'Sugestões',
          subtitle: 'O que o painel faz',
          tryLabel: 'Experimentar',
          items: _items,
          onTry: tried.add,
        ),
      );

      await tester.tap(find.text('Experimentar').last);

      expect(tried, [_items.last]);
    });

    testWidgets('closes the sheet from its close button', (tester) async {
      await tester.pumpComponent(
        TipsSheet(
          title: 'Sugestões',
          subtitle: 'O que o painel faz',
          tryLabel: 'Experimentar',
          items: _items,
          onTry: (_) {},
        ),
      );

      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
