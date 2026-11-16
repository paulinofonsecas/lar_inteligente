import 'package:a2ui_vgv_smart_home/theme/cubit/theme_cubit.dart';
import 'package:a2ui_vgv_smart_home/theme/panel_theme.dart';
import 'package:a2ui_vgv_smart_home/theme/theme_store.dart';
import 'package:flutter_test/flutter_test.dart';

/// A store the test keeps in memory.
class FakeThemeStore extends ThemeStore {
  FakeThemeStore([this.theme]);

  PanelTheme? theme;

  @override
  PanelTheme? read() => theme;

  @override
  void write(PanelTheme theme) => this.theme = theme;
}

void main() {
  group(ThemeCubit, () {
    test('starts on the time of day without a saved choice', () {
      expect(ThemeCubit(store: FakeThemeStore()).state, PanelTheme.auto);
    });

    test('starts on the saved choice', () {
      final cubit = ThemeCubit(store: FakeThemeStore(PanelTheme.dark));

      expect(cubit.state, PanelTheme.dark);
    });

    test('persists the chosen theme', () async {
      final store = FakeThemeStore();
      final cubit = ThemeCubit(store: store)..select(PanelTheme.dark);

      expect(cubit.state, PanelTheme.dark);
      expect(store.theme, PanelTheme.dark);
    });

    test('ignores a choice that changes nothing', () async {
      final store = FakeThemeStore(PanelTheme.light);
      final cubit = ThemeCubit(store: store);
      var emissions = 0;
      cubit.stream.listen((_) => emissions++);

      cubit.select(PanelTheme.light);
      await Future<void>.delayed(Duration.zero);

      expect(emissions, 0);
    });
  });

  group(ThemeStore, () {
    test('reads null before anything is written', () {
      expect(ThemeStore().read(), isNull);
    });

    test('writing outside the web keeps nothing, but never throws', () {
      final store = ThemeStore();

      expect(() => store.write(PanelTheme.dark), returnsNormally);
      expect(store.read(), isNull);
    });
  });
}
