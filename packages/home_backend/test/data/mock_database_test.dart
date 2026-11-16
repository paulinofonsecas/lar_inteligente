import 'dart:convert';
import 'dart:io';

import 'package:home_backend/data/mock_database.dart';
import 'package:test/test.dart';

const _users = {
  'users': [
    {'id': 'palmira', 'name': 'Palmira', 'role': 'Host'},
    {'id': 'paulino', 'name': 'Paulino', 'role': 'Logistics'},
  ],
};

const _home = {
  'now': '2026-10-10T16:30:00',
  'timeZone': 'America/Chicago',
  'structure': {'id': 's', 'name': 'Rivera Home'},
  'rooms': [
    {'id': 'kitchen', 'name': 'Kitchen'},
    {'id': 'garage', 'name': 'Garage'},
  ],
  'devices': [
    {'id': 'oven', 'room': 'kitchen', 'type': 'OvenDevice'},
    {'id': 'fridge', 'room': 'kitchen', 'type': 'RefrigeratorDevice'},
    {'id': 'car', 'room': 'garage', 'type': 'GoogleAutoDevice'},
  ],
  'groups': [
    {'id': 'g'},
  ],
  'automations': [
    {
      'id': 'dinner',
      'owners': ['palmira'],
    },
    {
      'id': 'charge',
      'owners': ['paulino'],
    },
  ],
};

const _calendar = {
  'source': 'Google Calendar',
  'timeZone': 'America/Chicago',
  'events': [
    {'id': 'c1', 'userId': 'palmira', 'start': '2026-10-10T19:00:00'},
    {'id': 'c2', 'userId': 'paulino', 'start': '2026-10-10T17:15:00'},
  ],
};

const _trips = {
  'source': 'Google Maps',
  'timeZone': 'America/Chicago',
  'trips': [
    {'id': 't1', 'userId': 'paulino'},
  ],
};

const _recipeTimeline = {
  'timeZone': 'America/Chicago',
  'steps': [
    {'userId': 'palmira', 'step': 'Preheat'},
  ],
};

const _todos = {
  'source': 'Synthetic',
  'lists': [
    {
      'id': 'shopping',
      'owners': ['palmira'],
      'sharedWith': ['paulino'],
      'items': <Object?>[],
    },
    {
      'id': 'chores',
      'owners': ['paulino'],
      'sharedWith': <String>[],
      'items': <Object?>[],
    },
  ],
};

const _bakery = {
  'name': 'Bakery',
  'orders': [
    {'id': 'o1', 'userId': 'paulino'},
  ],
  'messages': <Object?>[],
};

const _files = {
  'users.json': _users,
  'google_home.json': _home,
  'calendar.json': _calendar,
  'recipe_timeline.json': _recipeTimeline,
  'trips.json': _trips,
  'bakery.json': _bakery,
  'inbox.json': {'items': <Object?>[]},
  'todos.json': _todos,
};

List<String> _ids(Object? rows) => [
  for (final row in rows! as List<dynamic>) (row as Map)['id'] as String,
];

void main() {
  final database = MockDatabase(
    users: _users,
    home: _home,
    calendar: _calendar,
    recipeTimeline: _recipeTimeline,
    trips: _trips,
    todos: _todos,
  );

  group('MockDatabase', () {
    test('lists users as id, name and role', () {
      expect(database.listUsers(), [
        {'id': 'palmira', 'name': 'Palmira', 'role': 'Host'},
        {'id': 'paulino', 'name': 'Paulino', 'role': 'Logistics'},
      ]);
    });

    test('finds a user by id and returns null for an unknown one', () {
      expect(database.findUser('paulino')?['name'], 'Paulino');
      expect(database.findUser('nobody'), isNull);
    });

    test('requireUser throws a not found naming the available ids', () {
      expect(database.requireUser('palmira')['role'], 'Host');
      expect(
        () => database.requireUser('nobody'),
        throwsA(
          isA<MockDataNotFound>().having(
            (e) => e.toString(),
            'message',
            'Sem o usuário "nobody". Disponíveis: palmira, paulino.',
          ),
        ),
      );
    });

    group('homeFor', () {
      test("returns household wide data and the user's automations", () {
        final home = database.homeFor('paulino');

        expect(home['now'], '2026-10-10T16:30:00');
        expect(home['timeZone'], 'America/Chicago');
        expect(home['structure'], {'id': 's', 'name': 'Rivera Home'});
        expect(_ids(home['rooms']), ['kitchen', 'garage']);
        expect(_ids(home['devices']), ['oven', 'fridge', 'car']);
        expect(_ids(home['groups']), ['g']);
        expect(_ids(home['automations']), ['charge']);
      });

      test('leaves out data that does not come from Google Home', () {
        final keys = database.homeFor('palmira').keys;

        for (final other in ['calendar', 'trips', 'recipeTimeline']) {
          expect(keys, isNot(contains(other)));
        }
      });

      test('narrows automations to another user', () {
        expect(_ids(database.homeFor('palmira')['automations']), ['dinner']);
      });

      test('filters devices by room id or name without regard to case', () {
        expect(
          _ids(database.homeFor('palmira', room: 'kitchen')['devices']),
          ['oven', 'fridge'],
        );
        expect(
          _ids(database.homeFor('palmira', room: 'GARAGE')['devices']),
          ['car'],
        );
      });

      test('filters devices by device type without regard to case', () {
        expect(
          _ids(
            database.homeFor('palmira', deviceType: 'ovendevice')['devices'],
          ),
          ['oven'],
        );
      });

      test('combines the room and device type filters', () {
        expect(
          _ids(
            database.homeFor(
              'palmira',
              room: 'Kitchen',
              deviceType: 'RefrigeratorDevice',
            )['devices'],
          ),
          ['fridge'],
        );
      });

      test('throws for an unknown user', () {
        expect(
          () => database.homeFor('nobody'),
          throwsA(isA<MockDataNotFound>()),
        );
      });

      test('throws for an unknown room and lists the rooms', () {
        expect(
          () => database.homeFor('palmira', room: 'Attic'),
          throwsA(
            isA<MockDataNotFound>().having(
              (e) => e.message,
              'message',
              'Não há cômodo "Attic". Disponíveis: Kitchen, Garage.',
            ),
          ),
        );
      });

      test('throws for an unknown device type and lists the types', () {
        expect(
          () => database.homeFor('palmira', deviceType: 'Toaster'),
          throwsA(
            isA<MockDataNotFound>().having(
              (e) => e.message,
              'message',
              contains('Disponíveis: OvenDevice, RefrigeratorDevice'),
            ),
          ),
        );
      });

      test('throws when the filters match no device together', () {
        expect(
          () => database.homeFor(
            'palmira',
            room: 'Garage',
            deviceType: 'OvenDevice',
          ),
          throwsA(
            isA<MockDataNotFound>().having(
              (e) => e.message,
              'message',
              'Nenhum dispositivo no cômodo "Garage" com o tipo de dispositivo '
                  '"OvenDevice".',
            ),
          ),
        );
      });
    });
  });

  group('home write access', () {
    test('serves the live device maps, so a write is seen by every read', () {
      final read = database.homeFor('palmira')['devices']! as List<Object?>;

      expect(read.first, same(database.homeDevices.first));
      expect(database.homeGroups, hasLength(1));
    });

    test('scenes are the automations marked as scenes', () {
      expect(database.scenes, isEmpty);
    });

    test('serves to-do lists to their owners and recipients', () {
      expect(_ids(database.todoLists), ['shopping', 'chores']);
      expect(_ids(database.todosFor('palmira')['lists']), ['shopping']);
      expect(_ids(database.todosFor('paulino')['lists']), [
        'shopping',
        'chores',
      ]);
      expect(database.todosFor('palmira')['source'], 'Synthetic');
      expect(
        () => database.todosFor('nobody'),
        throwsA(isA<MockDataNotFound>()),
      );
    });

    test('has no to-do lists unless told otherwise', () {
      final bare = MockDatabase(
        users: {'users': <Map<String, dynamic>>[]},
        home: <String, dynamic>{},
      );
      expect(bare.todoLists, isEmpty);
    });
  });

  group('MockDatabase.load', () {
    test('reads every file from the directory through the loader', () async {
      final paths = <String>[];
      final loaded = await MockDatabase.load(
        directory: 'somewhere',
        loader: (path) async {
          paths.add(path);
          return jsonEncode(_files[path.split('/').last]);
        },
      );

      expect(paths, [
        'somewhere/users.json',
        'somewhere/google_home.json',
        'somewhere/calendar.json',
        'somewhere/recipe_timeline.json',
        'somewhere/trips.json',
        'somewhere/todos.json',
        'somewhere/bakery.json',
        'somewhere/inbox.json',
      ]);
      expect(loaded.listUsers(), hasLength(2));
    });

    test('reads from disk by default', () async {
      final directory = Directory.systemTemp.createTempSync('mock_db_');
      addTearDown(() => directory.deleteSync(recursive: true));
      _files.forEach((name, document) {
        File('${directory.path}/$name').writeAsStringSync(jsonEncode(document));
      });

      final loaded = await MockDatabase.load(directory: directory.path);

      expect(loaded.findUser('palmira'), isNotNull);
    });

    test('reads a profile photo for the users that have one', () async {
      final directory = Directory.systemTemp.createTempSync('mock_db_');
      addTearDown(() => directory.deleteSync(recursive: true));
      File('${directory.path}/palmira.jpg').writeAsBytesSync([1, 2, 3]);

      final loaded = await MockDatabase.load(
        directory: 'somewhere',
        photoDirectory: directory.path,
        loader: (path) async => jsonEncode(_files[path.split('/').last]),
      );

      expect(loaded.listProfiles(), [
        {
          'id': 'palmira',
          'name': 'Palmira',
          'role': 'Host',
          'photo': base64Encode([1, 2, 3]),
        },
        {'id': 'paulino', 'name': 'Paulino', 'role': 'Logistics'},
      ]);
      expect(loaded.listUsers().first, isNot(contains('photo')));
      expect(loaded.findUser('palmira'), isNot(contains('photo')));
    });

    test('fails when a file is missing', () {
      expect(
        MockDatabase.load(directory: 'does_not_exist'),
        throwsA(isA<FileSystemException>()),
      );
    });
  });

  group('the shipped data', () {
    late MockDatabase shipped;

    setUp(() async {
      shipped = await MockDatabase.load();
    });

    test('lists Palmira and Paulino, the two people in the timeline', () {
      expect(shipped.listUsers().map((u) => u['id']), ['palmira', 'paulino']);
    });

    test('has a photo for both', () {
      final photos = {
        for (final user in shipped.listProfiles())
          user['id']: user.containsKey('photo'),
      };

      expect(photos, {'palmira': true, 'paulino': true});
    });

    test('starts on Saturday at 7:30 AM', () {
      expect(shipped.clock.nowIso, '2026-10-10T07:30:00');
      expect(shipped.homeFor('palmira')['now'], '2026-10-10T07:30:00');
    });

    test('serves every user a full home model', () {
      for (final user in shipped.listUsers()) {
        final home = shipped.homeFor(user['id']! as String);
        expect(
          (home['structure']! as Map)['name'],
          'Casa Rivera',
        );
        expect(home['devices'], isNotEmpty);
      }
    });

    test('keeps only the dinner party scene as an automation', () {
      expect(_ids(shipped.homeFor('palmira')['automations']), ['dinner_party']);
      expect(shipped.homeFor('paulino')['automations'], isEmpty);
    });

    test('has exactly the devices the timeline uses', () {
      expect(
        shipped.homeDevices.map((d) => d['id']),
        [
          'oven',
          'fridge',
          'table_lights',
          'dining_speaker',
          'thermostat',
          'car',
          'front_door',
          'doorbell',
        ],
      );
    });

    test('has the dinner party scene, ready to start', () {
      expect(shipped.scenes.single, containsPair('state', 'ready'));
      expect(shipped.scenes.single['name'], 'Cena de jantar');
    });

    test(
      'serves the shopping list to its owner and to who it is shared with',
      () {
        final lists = shipped.todosFor('palmira')['lists']! as List<Object?>;
        expect((lists.single! as Map)['items'], hasLength(5));
        expect(shipped.todosFor('paulino')['lists'], isEmpty);
        shipped.todoLists.single['sharedWith'] = ['paulino'];
        expect(shipped.todosFor('paulino')['lists'], hasLength(1));
      },
    );
  });
}
