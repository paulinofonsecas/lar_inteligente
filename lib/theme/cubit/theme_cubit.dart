import 'package:a2ui_vgv_smart_home/theme/panel_theme.dart';
import 'package:a2ui_vgv_smart_home/theme/theme_store.dart';
import 'package:bloc/bloc.dart';

/// {@template theme_cubit}
/// Which appearance the panel draws: light, dark, or the one the demo's time
/// of day asks for.
///
/// The choice survives a reload through [ThemeStore]. The panel starts on
/// [PanelTheme.auto], which is light in the morning and dark at night, until
/// someone picks one.
/// {@endtemplate}
class ThemeCubit extends Cubit<PanelTheme> {
  /// {@macro theme_cubit}
  ThemeCubit({ThemeStore? store}) : this._(store ?? ThemeStore());

  ThemeCubit._(this._store) : super(_read(_store));

  final ThemeStore _store;

  static PanelTheme _read(ThemeStore store) => store.read() ?? PanelTheme.auto;

  /// Draws [theme] from now on, and saves it for the next visit.
  void select(PanelTheme theme) {
    if (theme == state) return;
    _store.write(theme);
    emit(theme);
  }
}
