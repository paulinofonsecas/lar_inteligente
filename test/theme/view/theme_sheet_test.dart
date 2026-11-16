import 'package:a2ui_vgv_smart_home/l10n/l10n.dart';
import 'package:a2ui_vgv_smart_home/theme/cubit/theme_cubit.dart';
import 'package:a2ui_vgv_smart_home/theme/panel_theme.dart';
import 'package:a2ui_vgv_smart_home/theme/theme_store.dart';
import 'package:a2ui_vgv_smart_home/theme/view/theme_sheet.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui/material_ui.dart' as mui;

/// A store the test keeps in memory.
class FakeThemeStore extends ThemeStore {
  PanelTheme? theme;

  @override
  PanelTheme? read() => theme;

  @override
  void write(PanelTheme theme) => this.theme = theme;
}

void main() {
  group(ThemeSheet, () {
    Future<void> pump(WidgetTester tester, ThemeCubit cubit) {
      return tester.pumpWidget(
        BlocProvider<ThemeCubit>.value(
          value: cubit,
          child: MaterialApp(
            theme: AppTheme.light,
            localizationsDelegates: const [
              ...AppLocalizations.localizationsDelegates,
              ...mui.GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: ThemeSheet()),
          ),
        ),
      );
    }

    testWidgets('shows one segment per theme, with the current one selected', (
      tester,
    ) async {
      final cubit = ThemeCubit(
        store: FakeThemeStore()..theme = PanelTheme.dark,
      );
      await pump(tester, cubit);

      expect(find.text('Claro'), findsOneWidget);
      expect(find.text('Escuro'), findsOneWidget);
      expect(find.text('Automático'), findsOneWidget);
      final segmented = tester.widget<SegmentedButton<PanelTheme>>(
        find.byType(SegmentedButton<PanelTheme>),
      );
      expect(segmented.selected, {PanelTheme.dark});
    });

    testWidgets('picking a theme changes and saves it', (tester) async {
      final store = FakeThemeStore();
      final cubit = ThemeCubit(store: store);
      await pump(tester, cubit);

      await tester.tap(find.text('Escuro'));
      await tester.pumpAndSettle();

      expect(cubit.state, PanelTheme.dark);
      expect(store.theme, PanelTheme.dark);
    });

    testWidgets('picking the time of day goes back to automatic', (
      tester,
    ) async {
      final store = FakeThemeStore()..theme = PanelTheme.light;
      final cubit = ThemeCubit(store: store);
      await pump(tester, cubit);

      await tester.tap(find.text('Automático'));
      await tester.pumpAndSettle();

      expect(cubit.state, PanelTheme.auto);
      expect(store.theme, PanelTheme.auto);
    });
  });
}
