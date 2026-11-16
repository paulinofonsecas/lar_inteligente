import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';

final _log = Logger('todos');

/// Where the shopping list lives when HOME_TODOS_FILE says nothing.
const defaultTodosFile = 'data-store/todos.json';

/// {@template todo_store}
/// The household's shopping list, kept in a file of its own.
///
/// Every visitor sees the same list: it is the house's, not the demo world's,
/// so it lives outside `MockDatabase`'s snapshot and outlives a `/reset`. The
/// file is created from the shipped seed the first time the server runs, and
/// rewritten whenever a command changes it.
/// {@endtemplate}
///
/// The path is `HOME_TODOS_FILE`, by default `data-store/todos.json` under the
/// working directory. A host with an ephemeral filesystem (such as the free
/// Render plan) keeps the list across restarts but not across a deploy: point
/// the variable at a mounted disk to keep it.
class TodoStore {
  TodoStore._(this.file, this.document);

  /// Reads the list from [file], seeding it from [seed] when the file is not
  /// there yet or cannot be read.
  ///
  /// A corrupt file is replaced by the seed and reported in the log: the demo
  /// stays up, and the next save writes a good file. Throws when the seed
  /// itself cannot be read, because nothing would seed the list.
  factory TodoStore.open({required String file, required String seed}) {
    final document = _read(file) ?? _seedFrom(seed);
    final store = TodoStore._(File(file), document);
    if (!store.file.existsSync()) store.save();
    return store;
  }

  /// The file the list is kept in.
  final File file;

  /// The list document, as `data/todos.json` has it. `MockDatabase` reads it
  /// and the device state machine writes it; whoever changes it calls [save].
  final Map<String, dynamic> document;

  static Map<String, dynamic>? _read(String file) {
    final handle = File(file);
    if (!handle.existsSync()) return null;
    try {
      final decoded = jsonDecode(handle.readAsStringSync());
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('not a JSON object');
      }
      return decoded;
    } on Object catch (error) {
      _log.severe(
        '$file could not be read; seeding the shopping list again',
        error,
      );
      return null;
    }
  }

  static Map<String, dynamic> _seedFrom(String seed) {
    final decoded = jsonDecode(File(seed).readAsStringSync());
    return decoded as Map<String, dynamic>;
  }

  /// Writes the list down, so the next request and the next boot read it.
  ///
  /// Synchronous on purpose: `/action` answers after the change is on disk. The
  /// file is written beside the target and renamed over it, so a crash mid
  /// write cannot leave half a list behind.
  void save() {
    file.parent.createSync(recursive: true);
    final temporary = File('${file.path}.writing')
      ..writeAsStringSync(jsonEncode(document), flush: true);
    try {
      file.deleteSync();
    } on FileSystemException {
      // Nothing was there to replace.
    }
    temporary.renameSync(file.path);
  }
}
