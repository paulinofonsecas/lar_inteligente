import 'package:a2ui_vgv_smart_home/theme/cubit/theme_cubit.dart';
import 'package:a2ui_vgv_smart_home/theme/theme_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// A store the test keeps in memory.
class FakeThemeStore extends ThemeStore {
  FakeThemeStore([this.mode]);

  ThemeMode? mode;

  @override
  ThemeMode? read() => mode;

  @override
  void write(ThemeMode mode) => this.mode = mode;
}

void main() {
  group(ThemeCubit, () {
    test('starts on the system theme without a saved choice', () {
      expect(ThemeCubit(store: FakeThemeStore()).state, ThemeMode.system);
    });

    test('starts on the saved choice', () {
      final cubit = ThemeCubit(store: FakeThemeStore(ThemeMode.dark));

      expect(cubit.state, ThemeMode.dark);
    });

    test('persists the chosen mode', () async {
      final store = FakeThemeStore();
      final cubit = ThemeCubit(store: store)..select(ThemeMode.dark);

      expect(cubit.state, ThemeMode.dark);
      expect(store.mode, ThemeMode.dark);
    });

    test('ignores a choice that changes nothing', () async {
      final store = FakeThemeStore(ThemeMode.light);
      final cubit = ThemeCubit(store: store);
      var emissions = 0;
      cubit.stream.listen((_) => emissions++);

      cubit.select(ThemeMode.light);
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

      expect(() => store.write(ThemeMode.dark), returnsNormally);
      expect(store.read(), isNull);
    });
  });
}
