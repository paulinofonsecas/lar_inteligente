import 'package:home_backend/data/mock_database.dart';
import 'package:home_backend/scenario/scenario_world.dart';
import 'package:home_backend/tools/agent_tool.dart';
import 'package:home_backend/tools/inbox_tools.dart';
import 'package:home_backend/tools/scenario_tools.dart';
import 'package:test/test.dart';

void main() {
  late MockDatabase database;
  late ScenarioWorld world;

  setUp(() async {
    database = await MockDatabase.load();
    world = ScenarioWorld(database);
  });

  Future<Map<String, Object?>> run(
    AgentTool tool,
    Map<String, dynamic> args,
  ) async => Map<String, Object?>.from((await tool.call(args))! as Map);

  group('get_inbox', () {
    test('is empty until somebody changes something', () async {
      final result = await run(inboxTool(database), {
        'user_id': 'paulino',
      });

      expect(result['unread'], 0);
      expect(result['items'], isEmpty);
    });

    test('shows Paulino what Palmira changed, with its suggestion', () async {
      await run(rescheduleGuestArrivalTool(world), {
        'shift_minutes': -60,
        'requested_by': 'palmira',
      });

      final result = await run(inboxTool(database), {
        'user_id': 'paulino',
      });

      expect(result['unread'], 1);
      final item = (result['items']! as List<dynamic>).single as Map;
      expect(item['title'], 'Jantar movido para 6:00 PM');
      expect(
        (item['suggestion'] as Map)['tool'],
        'request_bakery_delivery',
      );
    });

    test('hands an unknown user back to the model', () {
      expect(
        inboxTool(database).call({'user_id': 'nobody'}),
        throwsA(isA<MockDataNotFound>()),
      );
    });
  });

  group('mark_inbox_read', () {
    setUp(() async {
      await run(rescheduleGuestArrivalTool(world), {
        'shift_minutes': -60,
      });
    });

    test('marks everything read', () async {
      final result = await run(markInboxReadTool(world), {
        'user_id': 'paulino',
      });

      expect(result['markedRead'], 1);
      expect(database.inboxFor('paulino')['unread'], 0);
    });

    test('marks one item read', () async {
      final result = await run(markInboxReadTool(world), {
        'user_id': 'paulino',
        'item_id': 'inbox_1',
      });

      expect(result['markedRead'], 1);
    });

    test('hands a missing item back to the model', () {
      expect(
        markInboxReadTool(world).call({
          'user_id': 'paulino',
          'item_id': 'nope',
        }),
        throwsA(isA<MockDataNotFound>()),
      );
    });
  });

  test('asking the bakery to deliver settles the notification', () async {
    await run(rescheduleGuestArrivalTool(world), {
      'shift_minutes': -60,
    });

    await run(requestBakeryDeliveryTool(world), {'user_id': 'paulino'});

    expect(database.inboxFor('paulino')['unread'], 0);
  });

  test('only the owner of the pickup can ask the bakery to deliver', () {
    expect(
      requestBakeryDeliveryTool(world).call({'user_id': 'palmira'}),
      throwsA(isA<MockDataNotFound>()),
    );
  });
}
