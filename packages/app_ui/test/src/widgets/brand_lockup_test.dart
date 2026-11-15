import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../helpers/pump_component.dart';

const _lockup = BrandLockup(semanticLabel: 'Lar Inteligente');

void main() {
  group(BrandLockup, () {
    testWidgets('draws the lockup at its native 305 x 57', (tester) async {
      await tester.pumpComponent(_lockup);

      expect(
        tester.getSize(find.byType(BrandLockup)),
        const Size(305, 57),
      );
    });

    testWidgets('shows the house glyph and the brand name', (tester) async {
      await tester.pumpComponent(_lockup);

      expect(find.byIcon(Symbols.house_rounded), findsOneWidget);
      expect(find.text('Lar Inteligente'), findsOneWidget);
    });

    testWidgets('reads as the brand to assistive tech', (tester) async {
      await tester.pumpComponent(_lockup);

      expect(find.bySemanticsLabel('Lar Inteligente'), findsOneWidget);
    });
  });
}
