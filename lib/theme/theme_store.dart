import 'package:a2ui_vgv_smart_home/theme/panel_theme.dart';
import 'package:a2ui_vgv_smart_home/theme/theme_store_stub.dart'
    if (dart.library.js_interop) 'package:a2ui_vgv_smart_home/theme/theme_store_web.dart';

/// {@template theme_store}
/// Keeps the panel's appearance choice between visits.
///
/// The web build writes it to the browser storage; anywhere else, such as the
/// widget tests, it lives only in memory.
/// {@endtemplate}
class ThemeStore {
  /// {@macro theme_store}
  ThemeStore();

  static const _key = 'lar_inteligente.theme';

  /// The choice saved last, or null when nothing was saved.
  PanelTheme? read() => PanelTheme.byName(readSavedTheme(_key));

  /// Saves [theme] for the next visit.
  void write(PanelTheme theme) => writeSavedTheme(_key, theme.name);
}
