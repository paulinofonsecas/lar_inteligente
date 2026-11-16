import 'dart:io';

/// The worklet `record_web` loads by its literal path to capture raw PCM.
const _worklet = 'record.worklet';

/// The directory the built plugin assets land in.
final _js = Directory('build/web/assets/packages/record_web/assets/js');

/// Restores the plugin asset the web build renames behind the plugin's back.
///
/// `flutter build web --web-content-hash` renames every built asset to
/// `name.<hash>.ext`, but `record_web` asks `AudioWorklet.addModule` for
/// `assets/packages/record_web/assets/js/record.worklet.js`, without a hash.
/// The deployed site then answers 404 and the microphone cannot start, so the
/// voice commands go silent. This copies the hashed file back to the name the
/// plugin asks for. Run it after `flutter build web`, as `mise run build:web`
/// does.
void main() {
  if (!_js.existsSync()) {
    stderr.writeln('No ${_js.path}: run `flutter build web` first.');
    exit(1);
  }
  final hashed = _js
      .listSync()
      .whereType<File>()
      .where((file) => _hashed.hasMatch(_name(file)))
      .toList();
  if (hashed.isEmpty) {
    stderr.writeln('No hashed $_worklet.js in ${_js.path}.');
    exit(1);
  }
  for (final file in hashed) {
    file.copySync('${_js.path}/$_worklet.js');
  }
  stdout.writeln('Restored $_worklet.js from ${_name(hashed.first)}.');
}

final _hashed = RegExp('^${RegExp.escape(_worklet)}\\.[0-9a-f]+\\.js\$');

String _name(File file) => file.uri.pathSegments.last;
