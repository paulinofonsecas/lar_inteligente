import 'package:home_backend/data/mock_database.dart';
import 'package:home_backend/scenario/database_feed_source.dart';
import 'package:home_backend/scenario/inbox_service.dart';
import 'package:home_backend/scenario/scenario_world.dart';
import 'package:home_timeline/home_timeline.dart';
import 'package:test/test.dart';

void main() {
  late MockDatabase database;
  late ScenarioWorld world;

  setUp(() async {
    database = await MockDatabase.load();
    // The evening these tests walk starts at 4:30 PM, where the demo's Day is.
    world = ScenarioWorld(database)..moveTo(DateTime.utc(2026, 10, 10, 16, 30));
  });

  Matcher notFound(String text) => throwsA(
    isA<MockDataNotFound>().having(
      (e) => e.message,
      'message',
      contains(text),
    ),
  );

  List<Map<String, dynamic>> inboxOf(String userId) =>
      (database.inboxFor(userId)['items']! as List<dynamic>)
          .cast<Map<String, dynamic>>();

  group('InboxService', () {
    test('writes an unread item for the person it is for', () {
      final effect = world.inbox.post(
        to: 'paulino',
        from: 'palmira',
        kind: 'note',
        title: 'Hello',
        body: 'Hi Paulino.',
      );

      expect(effect, {
        'service': 'inbox',
        'action': 'notify',
        'to': 'paulino',
        'itemId': 'inbox_1',
        'title': 'Hello',
      });
      expect(inboxOf('palmira'), isEmpty);
      expect(inboxOf('paulino').single, {
        'id': 'inbox_1',
        'userId': 'paulino',
        'from': 'palmira',
        'at': '2026-10-10T16:30:00',
        'kind': 'note',
        'title': 'Hello',
        'body': 'Hi Paulino.',
        'read': false,
      });
      expect(database.inboxFor('paulino')['unread'], 1);
    });

    test('keeps the suggestion it was given', () {
      world.inbox.post(
        to: 'paulino',
        from: 'palmira',
        kind: 'note',
        title: 'Hello',
        body: 'Hi.',
        suggestion: {'tool': 'request_bakery_delivery'},
      );

      expect(inboxOf('paulino').single['suggestion'], {
        'tool': 'request_bakery_delivery',
      });
    });

    test('tells its listener about the item', () {
      final seen = <Map<String, Object?>>[];
      InboxService(database, onPosted: seen.add).post(
        to: 'paulino',
        from: 'palmira',
        kind: 'note',
        title: 'Hello',
        body: 'Hi.',
      );

      expect(seen.single['title'], 'Hello');
    });

    test('knows both people', () {
      expect(
        () => world.inbox.post(
          to: 'nobody',
          from: 'palmira',
          kind: 'k',
          title: 't',
          body: 'b',
        ),
        notFound('nobody'),
      );
      expect(
        () => world.inbox.post(
          to: 'palmira',
          from: 'nobody',
          kind: 'k',
          title: 't',
          body: 'b',
        ),
        notFound('nobody'),
      );
    });

    group('markRead', () {
      setUp(() {
        for (final title in ['One', 'Two']) {
          world.inbox.post(
            to: 'paulino',
            from: 'palmira',
            kind: 'note',
            title: title,
            body: title,
          );
        }
      });

      test('marks everything unread', () {
        final result = world.inbox.markRead('paulino');

        expect(result, {'userId': 'paulino', 'markedRead': 2});
        expect(database.inboxFor('paulino')['unread'], 0);
        expect(world.inbox.markRead('paulino')['markedRead'], 0);
      });

      test('marks one item', () {
        final result = world.inbox.markRead('paulino', itemId: 'inbox_1');

        expect(result['markedRead'], 1);
        expect(database.inboxFor('paulino')['unread'], 1);
      });

      test('names the items there are for one that is missing', () {
        expect(
          () => world.inbox.markRead('paulino', itemId: 'nope'),
          notFound('inbox_1, inbox_2'),
        );
        expect(() => world.inbox.markRead('nobody'), notFound('nobody'));
      });
    });
  });

  group('the inbox in the database', () {
    test('lists the newest first and hides what the clock has not reached', () {
      world.moveTo(atHhmm(database.clock.start, '17:00'));
      world.inbox.post(
        to: 'paulino',
        from: 'palmira',
        kind: 'note',
        title: 'Later',
        body: 'b',
      );
      world.moveTo(atHhmm(database.clock.start, '16:45'));

      expect(inboxOf('paulino'), isEmpty);

      world.moveTo(atHhmm(database.clock.start, '17:10'));
      world.inbox.post(
        to: 'paulino',
        from: 'palmira',
        kind: 'note',
        title: 'Newest',
        body: 'b',
      );

      expect(inboxOf('paulino').map((item) => item['title']), [
        'Newest',
        'Later',
      ]);
    });

    test('is empty for a database built without one', () {
      final bare = MockDatabase(
        users: {
          'users': [
            {'id': 'palmira'},
          ],
        },
        home: <String, dynamic>{},
      );

      expect(bare.inboxFor('palmira')['items'], isEmpty);
      expect(bare.inbox['items'], isEmpty);
      expect(() => bare.inboxFor('nobody'), notFound('nobody'));
    });

    test('goes back to empty on a reset', () {
      world.inbox.post(
        to: 'paulino',
        from: 'palmira',
        kind: 'note',
        title: 'Hello',
        body: 'Hi.',
      );

      world.reset();

      expect(inboxOf('paulino'), isEmpty);
    });

    test('has no items when the document has none', () {
      database.inbox.remove('items');

      expect(database.inboxItems, isEmpty);
    });
  });

  group('DinnerPlanner tells the people it concerns', () {
    test('Paulino hears Palmira moved the dinner, and what to do about it', () {
      final result = world.planner.moveGuests(
        shiftMinutes: -60,
        requestedBy: 'palmira',
      );

      expect(
        (result['effects']! as List<dynamic>).last,
        containsPair('to', 'paulino'),
      );
      expect(inboxOf('palmira'), isEmpty);
      final item = inboxOf('paulino').single;
      expect(item['from'], 'palmira');
      expect(item['title'], 'Jantar movido para 6:00 PM');
      expect(
        item['body'],
        'Palmira mudou o jantar de 7:00 PM para 6:00 PM. Sua rota agora '
        'chega em casa às 6:30–6:45 PM, depois das visitas.',
      );
      expect(
        item['suggestion'],
        containsPair('tool', 'request_bakery_delivery'),
      );
    });

    test('defaults to the owner of the dinner as the one who asked', () {
      world.planner.moveGuests(arrival: '18:00');

      expect(inboxOf('paulino'), hasLength(1));
      expect(inboxOf('palmira'), isEmpty);
    });

    test('Palmira hears when Paulino moves it, with nothing to fix', () {
      world.planner.moveGuests(shiftMinutes: -60, requestedBy: 'paulino');

      expect(inboxOf('paulino'), isEmpty);
      final item = inboxOf('palmira').single;
      expect(
        item['body'],
        'Paulino mudou o jantar de 7:00 PM para 6:00 PM.',
      );
      expect(item.containsKey('suggestion'), isFalse);
    });

    test('says what moved but offers nothing when the route still works', () {
      world.planner.moveGuests(shiftMinutes: 60);

      final item = inboxOf('paulino').single;
      expect(item['title'], 'Jantar movido para 8:00 PM');
      expect(
        item['body'],
        'Palmira mudou o jantar de 7:00 PM para 8:00 PM.',
      );
      expect(item.containsKey('suggestion'), isFalse);
    });

    test('does not offer a delivery that was already asked for', () {
      world.bakery.requestDelivery('paulino');

      world.planner.moveGuests(shiftMinutes: -60);

      final item = inboxOf('paulino').single;
      expect(item['body'], contains('depois das visitas'));
      expect(item.containsKey('suggestion'), isFalse);
    });

    test('does not tell anyone when nothing moved', () {
      world.planner.moveGuests(shiftMinutes: 0);

      expect(inboxOf('paulino'), isEmpty);
    });

    test('knows who asked', () {
      expect(
        () => world.planner.moveGuests(shiftMinutes: -60, requestedBy: 'x'),
        notFound('x'),
      );
    });
  });

  group('BakeryService', () {
    test(
      'only the person the pickup is assigned to can ask for a delivery',
      () {
        expect(
          () => world.bakery.requestDelivery('palmira'),
          notFound('está designada a paulino'),
        );
        expect(world.bakery.requestDelivery('paulino')['action'], 'requested');
      },
    );
  });

  group('ActivityFeed', () {
    late ActivityFeed feed;

    setUp(() => feed = ActivityFeed(DatabaseFeedSource(database)));

    List<String> summaries(Object? moments) => [
      for (final m in (moments! as List<dynamic>).cast<Map<String, Object?>>())
        m['summary']! as String,
    ];

    test("puts the pickup in Paulino's next and the dinner in both", () {
      world.moveTo(atHhmm(database.clock.start, '17:00'));

      expect(summaries(feed.forUser('paulino')['next']), [
        'Buscar na aula de piano',
        'Buscar bolo na padaria',
        'As visitas chegam',
      ]);
      expect(
        summaries(feed.forUser('palmira')['next']),
        contains('As visitas chegam'),
      );
    });

    test('shows a notification as what just happened to its person', () {
      world.planner.moveGuests(shiftMinutes: -60);

      final paulino = feed.forUser('paulino');

      expect(
        summaries(paulino['recent']),
        contains('Jantar movido para 6:00 PM'),
      );
      expect(
        (paulino['recent']! as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .firstWhere(
              (m) => m['kind'] == 'inbox',
            ),
        containsPair('by', 'palmira'),
      );
      expect(
        summaries(feed.forUser('palmira')['recent']),
        isNot(contains('Jantar movido para 6:00 PM')),
      );
    });
  });
}
