import 'package:a2ui_vgv_smart_home/l10n/l10n.dart';
import 'package:a2ui_vgv_smart_home/theme/cubit/theme_cubit.dart';
import 'package:a2ui_vgv_smart_home/theme/theme_store.dart';
import 'package:a2ui_vgv_smart_home/theme/view/theme_sheet.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui/material_ui.dart' as mui;

/// A store the test keeps in memory.
class FakeThemeStore extends ThemeStore {
  ThemeMode? mode;

  @override
  ThemeMode? read() => mode;

  @override
  void write(ThemeMode mode) => this.mode = mode;
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

    testWidgets('shows one segment per mode, with the current one selected', (
      tester,
    ) async {
      final store = FakeThemeStore()..mode = ThemeMode.dark;
      final cubit = ThemeCubit(store: store);
      await pump(tester, cubit);

      expect(find.text('Claro'), findsOneWidget);
      expect(find.text('Escuro'), findsOneWidget);
      expect(find.text('Sistema'), findsOneWidget);
      final segmented = tester.widget<SegmentedButton<ThemeMode>>(
        find.byType(SegmentedButton<ThemeMode>),
      );
      expect(segmented.selected, {ThemeMode.dark});
    });

    testWidgets('picking a mode changes and saves it', (tester) async {
      final store = FakeThemeStore();
      final cubit = ThemeCubit(store: store);
      await pump(tester, cubit);

      await tester.tap(find.text('Escuro'));
      await tester.pumpAndSettle();

      expect(cubit.state, ThemeMode.dark);
      expect(store.mode, ThemeMode.dark);
    });
  });
}
