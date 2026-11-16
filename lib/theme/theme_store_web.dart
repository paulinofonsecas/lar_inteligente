import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:material_ui/material_ui.dart';

/// Reads the saved theme mode from the browser's local storage.
ThemeMode? readThemeMode(String key) {
  try {
    final stored = _storage?.getProperty<JSString?>(key.toJS)?.toDart;
    return ThemeMode.values.where((mode) => mode.name == stored).firstOrNull;
  } on Object {
    // A browser with storage turned off must not take the panel down.
    return null;
  }
}

/// Saves the theme mode in the browser's local storage.
void writeThemeMode(String key, String value) {
  try {
    _storage?.setProperty(key.toJS, value.toJS);
  } on Object {
    // A browser with storage turned off must not take the panel down.
  }
}

JSObject? get _storage {
  final localStorage = globalContext['localStorage'];
  return localStorage.isA<JSObject>() ? localStorage! as JSObject : null;
}
