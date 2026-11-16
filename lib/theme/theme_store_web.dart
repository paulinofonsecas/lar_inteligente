import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Reads the saved theme from the browser's local storage.
String? readSavedTheme(String key) {
  try {
    return _storage?.getProperty<JSString?>(key.toJS)?.toDart;
  } on Object {
    // A browser with storage turned off must not take the panel down.
    return null;
  }
}

/// Saves the theme in the browser's local storage.
void writeSavedTheme(String key, String value) {
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
