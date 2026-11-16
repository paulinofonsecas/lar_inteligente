import 'package:material_ui/material_ui.dart';

/// Reads the saved theme mode outside the web, where nothing survives a
/// restart.
ThemeMode? readThemeMode(String key) => null;

/// Saves the theme mode outside the web, where nothing survives a restart.
void writeThemeMode(String key, String value) {}
