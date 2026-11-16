import 'package:home_backend/data/mock_database.dart';
import 'package:home_backend/live/live_hub.dart';
import 'package:home_backend/scenario/database_feed_source.dart';
import 'package:home_backend/scenario/scenario_world.dart';
import 'package:home_timeline/home_timeline.dart';
import 'package:test/test.dart';

/// The cake delivery from the request to the door: tool call, the bakery
/// scheduled, its times, the event on everyone's calendar.
void main() {
  late MockDatabase database;
  late LiveHub hub;
  late ScenarioWorld world;
  late List<Map<String, Object?>> frames;

  setUp(() async {
    database = await MockDatabase.load();
    hub = LiveHub();
    frames = [];
    hub.listen(frames.add);
    world = ScenarioWorld(database, live: hub);
  });

  void at(String time) => world.moveTo(atHhmm(database.clock.start, time));

  Map<String, dynamic> delivery() => database.calendarEvents.firstWhere(
    (e) => e['id'] == 'cal_cake_delivery',
  );

  List<String> bakeryRefreshes() => [
    for (final f in frames)
      if (f['type'] == 'changed' && f['reason'] == 'bakery')
        (f['users']! as List<dynamic>).join(','),
  ];

  group('the cake delivery', () {
    test('is on the calendar of both of them as soon as it is asked for', () {
      at('16:39');
      world.bakery.requestDelivery('paulino');
      world.reconcile();

      expect(delivery()['status'], 'tentative');
      expect(database.assigneesOf(delivery()), ['paulino', 'palmira']);
    });

    test('says when it leaves the bakery and when it arrives', () {
      at('16:39');
      world.bakery.requestDelivery('paulino');
      at('16:41');

      expect(delivery()['status'], 'confirmed');
      expect(delivery()['start'], '2026-10-10T17:20:00');
      expect(delivery()['end'], '2026-10-10T17:45:00');
      expect(delivery()['leavesAt'], '5:20 PM');
      expect(delivery()['arrivesAt'], '5:45 PM');
      expect(
        delivery()['detail'],
        'Sai da padaria 5:20 PM · chega em casa 5:45 PM · 25 min',
      );
    });

    test('the pickup stays until the bakery confirms, then it is gone', () {
      at('16:39');
      world.bakery.requestDelivery('paulino');
      world.reconcile();
      expect(
        database.calendarEvents.firstWhere(
          (e) => e['id'] == 'cal_cake',
        )['status'],
        'confirmed',
      );

      at('16:41');
      expect(
        database.calendarEvents.firstWhere(
          (e) => e['id'] == 'cal_cake',
        )['status'],
        'cancelled',
      );
    });

    test('both feeds carry the event with its times', () {
      at('16:39');
      world.bakery.requestDelivery('paulino');
      at('16:41');

      for (final user in ['palmira', 'paulino']) {
        final next =
            (ActivityFeed(DatabaseFeedSource(database)).forUser(user)['next']!
                    as List<dynamic>)
                .cast<Map<String, Object?>>()
                .where((m) => m['kind'] == 'calendar')
                .map((m) => m['summary']);
        expect(
          next,
          contains(
            'Entrega do bolo da padaria: Sai da padaria 5:20 PM · '
            'chega em casa 5:45 PM · 25 min',
          ),
        );
      }
    });

    test('the bar reads full in the last two minutes', () {
      at('16:39');
      world.bakery.requestDelivery('paulino');

      at('17:42');
      var order =
          (database.bakeryFor('palmira')['orders']! as List<dynamic>).single
              as Map;
      expect(order['progressPercent'], lessThan(100));

      at('17:43');
      order =
          (database.bakeryFor('palmira')['orders']! as List<dynamic>).single
              as Map;
      expect(order['status'], 'out_for_delivery');
      expect(order['progressPercent'], 100);
    });

    test('is tracked by the one at home too, halfway and at the door', () {
      at('16:39');
      world.bakery.requestDelivery('paulino');

      at('17:30');
      for (final user in ['palmira', 'paulino']) {
        final order =
            (database.bakeryFor(user)['orders']! as List<dynamic>).single
                as Map;
        expect(order['status'], 'out_for_delivery');
        expect(order['progressPercent'], 40);
        expect(
          order['statusLabel'],
          'Em andamento · faltam 15 min, chega às 5:45 PM',
        );
        final recent =
            (ActivityFeed(DatabaseFeedSource(database)).forUser(user)['recent']!
                    as List<dynamic>)
                .map((m) => (m as Map)['summary']);
        expect(
          recent.where(
            (s) => (s! as String).startsWith(
              'O bolo está a caminho, 40% do trajeto, '
              'faltam 15 min, chega às 5:45 PM',
            ),
          ),
          hasLength(1),
        );
      }

      at('17:45');
      final order =
          (database.bakeryFor('palmira')['orders']! as List<dynamic>).single
              as Map;
      expect(order['status'], 'delivered');
    });

    test('refreshes the others screens, without an inbox item', () {
      at('16:39');
      world.bakery.requestDelivery('paulino');
      frames.clear();

      world.notifyDeliveryRequested('paulino');

      expect(bakeryRefreshes(), ['palmira']);
      expect(database.inboxFor('palmira')['items'], isEmpty);
      expect(database.inboxFor('paulino')['items'], isEmpty);
    });

    test('refreshes both screens as it moves on, once per stage', () {
      at('16:39');
      world.bakery.requestDelivery('paulino');
      frames.clear();

      for (final time in [
        '16:40',
        '16:41',
        '16:42',
        '17:19',
        '17:20',
        '17:21',
      ]) {
        at(time);
      }
      // Confirmed at 4:40 (only once), left the bakery at 5:20.
      expect(bakeryRefreshes(), ['paulino,palmira', 'paulino,palmira']);

      for (final time in [
        '17:30',
        '17:34',
        '17:33',
        '17:44',
        '17:45',
        '17:46',
      ]) {
        at(time);
      }
      // A quarter at 5:30 and at 5:34 (not again at 5:33), full at 5:44, then
      // delivered at 5:45.
      expect(bakeryRefreshes(), hasLength(6));
    });

    test('a rewind takes the event back off the calendar', () {
      at('16:39');
      world.bakery.requestDelivery('paulino');
      at('16:41');
      expect(delivery(), isNotNull);

      world.moveTo(atHhmm(database.clock.start, '16:30'));

      expect(
        database.calendarEvents.where((e) => e['id'] == 'cal_cake_delivery'),
        isEmpty,
      );
    });
  });
}
