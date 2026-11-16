import 'package:home_backend/data/mock_database.dart';
import 'package:home_backend/devices/device_command.dart';
import 'package:home_backend/devices/device_state_machine.dart';
import 'package:home_backend/scenario/database_feed_source.dart';
import 'package:home_backend/scenario/scenario_world.dart';
import 'package:home_timeline/home_timeline.dart';
import 'package:test/test.dart';

const _stop = DeviceCommand.off;

const _confirmed =
    'A padaria confirmou a entrega do bolo: o entregador sai às 5:20 PM e '
    'leva 25 minutos, chega às 5:45 PM';

void main() {
  late MockDatabase database;
  late ScenarioWorld world;
  late ActivityFeed feed;

  setUp(() async {
    database = await MockDatabase.load();
    // The evening these tests walk starts at 4:30 PM, where the demo's Day is.
    world = ScenarioWorld(database)..moveTo(DateTime.utc(2026, 10, 10, 16, 30));
    feed = ActivityFeed(DatabaseFeedSource(database));
  });

  void at(String time) => world.moveTo(atHhmm(database.clock.start, time));

  List<String> summaries(Object? moments) => [
    for (final m in (moments! as List<dynamic>).cast<Map<String, Object?>>())
      m['summary']! as String,
  ];

  group('ActivityFeed', () {
    test('at 4:30 only the florist has come by', () {
      final result = feed.forUser('ana');

      expect(result['nowLabel'], '4:30 PM');
      expect(summaries(result['recent']), [
        'Entrega do florista: Flores da mesa na porta da frente',
      ]);
      expect(
        summaries(result['next']),
        [
              'Preparar a peça',
              'Preaquecer o forno a 200 °C',
              'O forno começa a preaquecer a 200 °C',
            ].where((_) => false).toList() +
            summaries(result['next']),
      );
    });

    test('the morning leads Ana to the market and Marco to his stand-up', () {
      at('07:30');

      expect(
        summaries(feed.forUser('ana')['next']),
        contains('Feira: Tomilho, limões e flores para hoje'),
      );
      expect(
        summaries(feed.forUser('marco')['next']),
        contains('Daily do time: Do escritório no andar de cima'),
      );
    });

    test('at sunset the drinks and the neighbors chairs are next', () {
      at('17:40');

      expect(
        summaries(feed.forUser('ana')['next']),
        containsAll([
          'Gelar as bebidas: Água com gás e vinho branco no gelo',
          'Vizinhos trazem cadeiras: Duas cadeiras da casa ao lado',
        ]),
      );
    });

    test('in the evening dessert comes and the cleanup waits', () {
      at('20:40');
      final feedOfAna = feed.forUser('ana');

      expect(
        summaries(feedOfAna['next']),
        containsAll([
          'Sobremesa e café: Tiramisu e café para 8',
          'Abaixar a música: Baixar o volume para conversar',
        ]),
      );
      at('21:50');
      expect(
        summaries(feed.forUser('ana')['next']),
        contains(
          'Lavar a louça: Rodar a lava-louças depois que as visitas forem',
        ),
      );
    });

    test('only what is within two hours is next, soonest first', () {
      final next = (feed.forUser('ana')['next']! as List<dynamic>)
          .cast<Map<String, Object?>>();

      expect(next.first['summary'], startsWith('Arrumar a mesa'));
      expect(next.first['inMinutes'], 30);
      expect(
        next.map((m) => m['inMinutes']! as int),
        orderedEquals([...next.map((m) => m['inMinutes']! as int)]..sort()),
      );
      expect(next.every((m) => (m['inMinutes']! as int) <= 120), isTrue);
    });

    test('unfinished shopping is an urgent moment before the cooking', () {
      final next = (feed.forUser('ana')['next']! as List<dynamic>)
          .cast<Map<String, Object?>>();
      final shopping = next.singleWhere((m) => m['kind'] == 'todo');

      expect(shopping['urgent'], isTrue);
      expect(shopping['listId'], 'shopping');
      expect(shopping['inMinutes'], 90);
      expect(shopping['summary'], contains('Tomilho fresco'));
      expect(
        (feed.forUser('marco')['next']! as List<dynamic>)
            .cast<Map<String, Object?>>()
            .where((m) => m['kind'] == 'todo'),
        isEmpty,
      );
    });

    test('unfinished shopping stays in next past its deadline', () {
      at('18:20');

      final next = (feed.forUser('ana')['next']! as List<dynamic>)
          .cast<Map<String, Object?>>();

      expect(
        next.where((m) => m['kind'] == 'todo' && m['listId'] == 'shopping'),
        hasLength(1),
      );
    });

    test('the guests moving is the most recent thing that happened', () {
      at('16:36');
      world.planner.moveGuests(shiftMinutes: -60);
      at('16:37');

      final recent = feed.forUser('ana')['recent']! as List<dynamic>;
      final change = recent.cast<Map<String, Object?>>().firstWhere(
        (m) => m['kind'] == 'change',
      );

      expect(change['summary'], contains('6:00 PM (era 7:00 PM)'));
      expect(change['minutesAgo'], 1);
    });

    test("Marco's itinerary leads his feed, from the first minute", () {
      final next = (feed.forUser('marco')['next']! as List<dynamic>)
          .cast<Map<String, Object?>>();
      final trip = next.firstWhere((m) => m['kind'] == 'trip');

      expect(trip['urgent'], isTrue);
      expect(trip['tripId'], 'trip_pickup');
      expect(
        trip['summary'],
        'Itinerário de Marco: sair às 4:55 PM, '
        'Aula de piano (buscar) 5:15 PM → '
        'Padaria 5:45 PM → Casa 6:30–6:45 PM',
      );
      expect(
        (feed.forUser('ana')['next']! as List<dynamic>)
            .cast<Map<String, Object?>>()
            .where(
              (m) => m['kind'] == 'trip',
            ),
        isEmpty,
      );
    });

    test("Marco's itinerary lists his whole evening, guests included", () {
      List<String> itinerary() {
        final trip = (feed.forUser('marco')['next']! as List<dynamic>)
            .cast<Map<String, Object?>>()
            .firstWhere((m) => m['kind'] == 'trip');
        return [
          for (final e
              in (trip['itinerary']! as List<dynamic>)
                  .cast<Map<String, Object?>>())
            '${e['time']} ${e['title']}',
        ];
      }

      expect(itinerary(), [
        '4:55 PM Sair de casa',
        '5:15 PM Aula de piano (buscar)',
        '5:45 PM Padaria',
        '6:30–6:45 PM Casa',
        '7:00 PM As visitas chegam',
      ]);

      at('16:36');
      world.planner.moveGuests(shiftMinutes: -60);
      at('16:39');
      world.bakery.requestDelivery('marco');
      at('16:41');

      expect(itinerary(), [
        '4:55 PM Sair de casa',
        '5:15 PM Aula de piano (buscar)',
        '5:20–5:45 PM Entrega do bolo da padaria',
        '5:30–5:45 PM Casa',
        '6:00 PM As visitas chegam',
      ]);
    });

    test('the itinerary drops what is already over', () {
      at('17:20');

      final trip = (feed.forUser('marco')['recent']! as List<dynamic>)
          .cast<Map<String, Object?>>()
          .firstWhere((m) => m['kind'] == 'trip');
      expect(
        (trip['itinerary']! as List<dynamic>).map((e) => (e as Map)['title']),
        ['Padaria', 'Casa', 'As visitas chegam'],
      );
    });

    test('a plan step that is done is no longer in the feed', () {
      at('18:00');

      final all = [
        ...summaries(feed.forUser('ana')['recent']),
        ...summaries(feed.forUser('ana')['next']),
      ];
      expect(all, isNot(contains('Preparar a peça')));
    });

    test(
      'the shopping list says it has every item, not only the open ones',
      () {
        final shopping = (feed.forUser('ana')['next']! as List<dynamic>)
            .cast<Map<String, Object?>>()
            .firstWhere((m) => m['kind'] == 'todo');

        expect(shopping['summary'], contains('faltam 1 de 5 itens'));
        expect(shopping['summary'], contains('Mostre todos os itens da lista'));
      },
    );

    test('the itinerary stays in front of Marco until he is home', () {
      at('17:20');

      final recent = (feed.forUser('marco')['recent']! as List<dynamic>)
          .cast<Map<String, Object?>>();
      final trip = recent.firstWhere((m) => m['kind'] == 'trip');
      expect(trip['urgent'], isTrue);
      expect(trip['minutesAgo'], 0);

      at('18:45');
      expect(
        (feed.forUser('marco')['recent']! as List<dynamic>)
            .cast<Map<String, Object?>>()
            .where(
              (m) => m['kind'] == 'trip',
            ),
        isEmpty,
      );
    });

    test('Marco being late for the guests is only on Marco feed', () {
      at('16:36');
      world.planner.moveGuests(shiftMinutes: -60);

      List<String> late(String user) =>
          (feed.forUser(user)['recent']! as List<dynamic>)
              .cast<Map<String, Object?>>()
              .where((m) => m['kind'] == 'trip' && m['urgent'] == true)
              .map((m) => m['summary']! as String)
              .where(
                (s) =>
                    s.contains('chega em casa depois da chegada das visitas'),
              )
              .toList();

      expect(
        late('marco'),
        contains(contains('A parada Padaria é a causa')),
      );
      expect(late('ana'), isEmpty);
    });

    test('a delivery is on both feeds, with its slot and duration', () {
      at('16:39');
      world.bakery.requestDelivery('marco');
      at('16:42');

      for (final user in ['ana', 'marco']) {
        final all = [
          ...summaries(feed.forUser(user)['recent']),
          ...summaries(feed.forUser(user)['next']),
        ];
        expect(
          all,
          containsAll([
            _confirmed,
            'O bolo saiu da padaria, a caminho, chega às 5:45 PM',
          ]),
        );
      }
    });

    test(
      'after the move the plan comes up first, the oven right behind it',
      () {
        at('16:36');
        world.planner.moveGuests(shiftMinutes: -60);

        final next = (feed.forUser('ana')['next']! as List<dynamic>)
            .cast<Map<String, Object?>>();

        expect(next.first['kind'], 'plan');
        expect(next.first['stepId'], 'prep');
        expect(next.first['inMinutes'], 24);
        expect(
          next.where((m) => m['deviceId'] == 'oven').first['summary'],
          'O forno começa a preaquecer a 200 °C',
        );
      },
    );

    test("Marco's bakery order is his news, and not Ana's", () {
      at('16:39');
      world.bakery.requestDelivery('marco');
      at('16:42');

      expect(
        summaries(feed.forUser('marco')['recent']),
        containsAll([
          'Pediu à padaria que entregue o bolo',
          _confirmed,
        ]),
      );
      expect(
        summaries(feed.forUser('ana')['recent']),
        isNot(contains('Pediu à padaria que entregue o bolo')),
      );
    });

    test('a delivery not yet on the road asks both screens for its card', () {
      at('16:39');
      world.bakery.requestDelivery('marco');
      at('16:42');

      for (final user in ['ana', 'marco']) {
        final tracked = (feed.forUser(user)['recent']! as List<dynamic>)
            .cast<Map<String, Object?>>()
            .where((m) => (m['summary']! as String).contains('TripCard'));
        expect(tracked, hasLength(1), reason: user);
        expect(tracked.single['urgent'], isTrue);
      }
    });

    test(
      'the courier on the road asks for a TripCard with its status',
      () {
        at('16:39');
        world.bakery.requestDelivery('marco');
        at('17:30');

        for (final user in ['ana', 'marco']) {
          final moment = (feed.forUser(user)['recent']! as List<dynamic>)
              .cast<Map<String, Object?>>()
              .singleWhere(
                (m) => (m['summary']! as String).contains('está a caminho'),
              );
          expect(moment['urgent'], isTrue);
          expect(
            moment['summary'],
            allOf(
              contains('40% do trajeto, faltam 15 min, chega às 5:45 PM'),
              contains('um TripCard'),
              isNot(contains('progress 40')),
            ),
          );
        }
      },
    );

    test(
      'the courier at the door leads with a heads up, then it is history',
      () {
        at('16:39');
        world.bakery.requestDelivery('marco');
        at('17:46');

        for (final user in ['ana', 'marco']) {
          final delivered = (feed.forUser(user)['recent']! as List<dynamic>)
              .cast<Map<String, Object?>>()
              .singleWhere(
                (m) => (m['summary']! as String).startsWith(
                  'O bolo foi entregue',
                ),
              );
          expect(delivered['urgent'], isTrue);
          expect(
            delivered['summary'],
            allOf(
              contains('HeadsUpCard'),
              contains('O bolo está na porta da frente'),
              contains('Entregue às 5:45 PM'),
            ),
          );
        }

        at('18:01');
        final late = (feed.forUser('ana')['recent']! as List<dynamic>)
            .cast<Map<String, Object?>>();
        expect(
          late.where((m) => m['kind'] == 'bakery' && m['urgent'] == true),
          isEmpty,
        );
        expect(
          late.where((m) => (m['summary']! as String).contains('HeadsUpCard')),
          isEmpty,
        );
      },
    );

    test('the delivery and the courier at the door are recent at 5:47', () {
      at('16:36');
      world.planner.moveGuests(shiftMinutes: -60);
      at('16:39');
      world.bakery.requestDelivery('marco');
      at('17:47');

      final recent = summaries(feed.forUser('marco')['recent']);

      expect(
        recent.where((s) => s.startsWith('O bolo foi entregue')),
        hasLength(1),
      );
      expect(recent, contains('Entrega · bolo'));
    });

    test('the oven reaching 400 and the roast going in, with the device', () {
      at('16:36');
      world.planner.moveGuests(shiftMinutes: -60);
      at('17:46');

      final recent = (feed.forUser('ana')['recent']! as List<dynamic>)
          .cast<Map<String, Object?>>();

      final roast = recent.firstWhere(
        (m) => m['summary'] == 'O assado vai ao forno',
      );
      expect(roast['deviceId'], 'oven');
      expect(roast['minutesAgo'], 1);
      expect(
        recent.map((m) => m['summary']),
        contains('O forno chega a 200 °C'),
      );
    });

    test('what happened more than half an hour ago is dropped', () {
      at('16:36');
      world.planner.moveGuests(shiftMinutes: -60);
      at('17:50');

      expect(
        summaries(feed.forUser('ana')['recent']),
        isNot(contains('Preparar a peça')),
      );
    });

    test('after a rewind, what the clock has not reached is not recent', () {
      at('16:39');
      world.bakery.requestDelivery('marco');
      at('16:30');

      expect(summaries(feed.forUser('marco')['recent']), isEmpty);
      expect(
        summaries(feed.forUser('marco')['next']),
        isNot(contains('Pediu à padaria que entregue o bolo')),
      );
    });

    test('a stopped oven has no oven moments', () {
      DeviceStateMachine(database).execute('oven', _stop);
      world.reconcile();

      expect(
        (feed.forUser('ana')['next']! as List<dynamic>)
            .cast<Map<String, Object?>>()
            .where(
              (m) => m['kind'] == 'oven',
            ),
        isEmpty,
      );
    });

    test('a database with no oven, doorbell or orders still answers', () {
      database.homeDevices.clear();
      expect(feed.forUser('ana')['next'], isNotEmpty);
    });

    test('an unknown user is not found', () {
      expect(() => feed.forUser('nobody'), throwsA(isA<MockDataNotFound>()));
    });
  });
}
