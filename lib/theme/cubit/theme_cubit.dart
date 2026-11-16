import 'package:a2ui_vgv_smart_home/theme/theme_store.dart';
import 'package:bloc/bloc.dart';
import 'package:material_ui/material_ui.dart';

/// {@template theme_cubit}
/// Which appearance the panel draws: light, dark, or whatever the device
/// around it is set to.
///
/// The choice survives a reload through [ThemeStore]. The panel starts on
/// [ThemeMode.system] until someone picks one.
/// {@endtemplate}
class ThemeCubit extends Cubit<ThemeMode> {
  /// {@macro theme_cubit}
  ThemeCubit({ThemeStore? store}) : this._(store ?? ThemeStore());

  ThemeCubit._(this._store) : super(_read(_store));

  final ThemeStore _store;

  static ThemeMode _read(ThemeStore store) => store.read() ?? ThemeMode.system;

  /// Draws [mode] from now on, and saves it for the next visit.
  void select(ThemeMode mode) {
    if (mode == state) return;
    _store.write(mode);
    emit(mode);
  }
}
