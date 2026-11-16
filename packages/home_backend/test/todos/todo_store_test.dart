import 'dart:convert';
import 'dart:io';

import 'package:home_backend/todos/todo_store.dart';
import 'package:test/test.dart';

/// The seed the demo ships, read once.
final _seed = File('data/todos.json').readAsStringSync();

void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('todo_store_test');
  });

  tearDown(() => directory.delete(recursive: true));

  String path([String name = 'todos.json']) => '${directory.path}/$name';

  group(TodoStore, () {
    test('creates the file from the seed the first time it runs', () {
      final store = TodoStore.open(file: path(), seed: 'data/todos.json');

      expect(File(path()).existsSync(), isTrue);
      expect(jsonDecode(File(path()).readAsStringSync()), store.document);
      expect(store.document, jsonDecode(_seed));
    });

    test('reads the list it wrote before', () {
      final first = TodoStore.open(file: path(), seed: 'data/todos.json');
      ((first.document['lists'] as List<dynamic>).first
          as Map<String, dynamic>)['sharedWith'] = [
        'paulino',
      ];
      first.save();

      final second = TodoStore.open(file: path(), seed: 'data/todos.json');

      expect(
        ((second.document['lists'] as List<dynamic>).first
            as Map<String, dynamic>)['sharedWith'],
        ['paulino'],
      );
    });

    test('goes back to the seed when the file is not readable', () {
      File(path())
        ..createSync(recursive: true)
        ..writeAsStringSync('{ half');

      final store = TodoStore.open(file: path(), seed: 'data/todos.json');

      expect(store.document, jsonDecode(_seed));
      // The next save replaces the broken file.
      store.save();
      expect(jsonDecode(File(path()).readAsStringSync()), store.document);
    });

    test('keeps no temporary file behind', () {
      final store = TodoStore.open(file: path(), seed: 'data/todos.json')
        ..save();

      expect(File('${path()}.writing').existsSync(), isFalse);
      expect(store.document, isNotEmpty);
    });

    test('creates the directory the file lives in', () {
      final nested = '${directory.path}/data-store/nested/todos.json';

      TodoStore.open(file: nested, seed: 'data/todos.json');

      expect(File(nested).existsSync(), isTrue);
    });
  });
}
