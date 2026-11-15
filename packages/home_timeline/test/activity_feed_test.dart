import 'package:home_timeline/home_timeline.dart';
import 'package:test/test.dart';

class _Source implements FeedSource {
  _Source(this.now);

  @override
  DateTime now;

  @override
  String userName(String userId) {
    if (userId != 'ana') throw ArgumentError('No user $userId');
    return 'Ana';
  }

  final devices = <String, Map<String, dynamic>>{};

  @override
  Map<String, dynamic>? device(String id) => devices[id];

  @override
  List<Map<String, dynamic>> recipeSteps = [
    {'id': 'prep', 'step': 'Prep the rack', 'at': '17:00', 'userId': 'ana'},
    {'id': 'old', 'step': 'Shop', 'at': '15:00', 'userId': 'ana', 'done': true},
  ];

  @override
  List<Map<String, dynamic>> todoLists = [];

  @override
  List<Map<String, dynamic>> orders = [];

  @override
  List<Map<String, dynamic>> bakeryMessages = [];

  @override
  List<Map<String, dynamic>> trips = [];

  @override
  List<Map<String, dynamic>> calendarEvents = [
    {
      'start': '2026-10-10T18:00:00',
      'title': 'Pick up wine',
      'detail': 'Market',
      'assignedTo': ['ana', 'marco'],
    },
    {
      'start': '2026-10-10T18:30:00',
      'title': 'Dinner',
      'kind': 'guests_arrive',
    },
    {'start': '2026-10-10T20:00:00', 'title': 'Old', 'status': 'cancelled'},
  ];

  @override
  List<String> assigneesOf(Map<String, dynamic> event) =>
      (event['assignedTo'] as List<dynamic>? ?? const ['ana']).cast<String>();

  @override
  List<Map<String, dynamic>> inboxItems = [];
}

List<String> _summaries(Object? moments) => [
  for (final m in (moments! as List<dynamic>).cast<Map<String, Object?>>())
    m['summary']! as String,
];

void main() {
  late _Source source;
  late ActivityFeed feed;

  setUp(() {
    source = _Source(DateTime.utc(2026, 10, 10, 16, 30));
    feed = ActivityFeed(source);
  });

  test('lists what is coming up within the window, soonest first', () {
    final result = feed.forUser('ana');

    expect(result['nowLabel'], '4:30 PM');
    expect(result['recent'], isEmpty);
    expect(_summaries(result['next']), [
      'Prep the rack',
      'Pick up wine: Market',
      'As visitas chegam',
    ]);
  });

  test('moves a moment to recent once the clock passes it', () {
    source.now = DateTime.utc(2026, 10, 10, 17, 10);

    final recent = feed.forUser('ana')['recent']! as List<dynamic>;

    expect(_summaries(recent), ['Prep the rack']);
    expect((recent.first as Map<String, Object?>)['minutesAgo'], 10);
  });

  test('keeps only what concerns the user', () {
    source.calendarEvents.first['assignedTo'] = ['marco'];

    expect(
      _summaries(feed.forUser('ana')['next']),
      isNot(contains('Pick up wine: Market')),
    );
  });

  test('shows a to-do list as urgent however far off its deadline is', () {
    source.todoLists = [
      {
        'id': 'groceries',
        'title': 'Groceries',
        'dueBeforeStep': 'prep',
        'owners': ['ana'],
        'items': [
          {'label': 'Eggs'},
          {'label': 'Milk', 'checked': true},
        ],
      },
    ];
    source.recipeSteps.first['at'] = '23:00';

    final next = (feed.forUser('ana')['next']! as List<dynamic>)
        .cast<Map<String, Object?>>();

    expect(next.last['listId'], 'groceries');
    expect(next.last['urgent'], isTrue);
    expect(
      next.last['summary'],
      contains('faltam 1 de 2 itens: Eggs'),
    );
  });

  test('throws for an unknown user', () {
    expect(() => feed.forUser('nobody'), throwsArgumentError);
  });

  group('with every source', () {
    setUp(() {
      source
        ..now = DateTime.utc(2026, 10, 10, 17, 50)
        ..devices['oven'] = {
          'traits': {
            'CookSchedule': {
              'readyAt': '17:30',
              'roastInAt': '17:40',
              'doneAt': '18:40',
            },
            'TemperatureControl': {
              'scheduledStart': '17:00',
              'temperatureSetpoint': 200,
            },
          },
        }
        ..devices['doorbell'] = {
          'traits': {
            'DoorbellPress': {'lastPressAt': '2026-10-10T17:45:00'},
            'DoorbellEvent': {'label': 'Entrega · bolo'},
          },
        }
        ..orders = [
          {
            'userId': 'ana',
            'item': 'Bolo',
            'bakeryName': 'Doce Ponto',
            'requestedAt': '2026-10-10T16:40:00',
            'confirmsAt': '2026-10-10T16:50:00',
            'departsAt': '2026-10-10T17:20:00',
            'eta': '2026-10-10T17:45:00',
            'durationMinutes': 25,
            'status': 'delivered',
          },
        ]
        ..bakeryMessages = [
          {'at': '2026-10-10T17:30:00', 'text': 'Pediu um horário mais tarde'},
        ]
        ..trips = [
          {
            'id': 'drive',
            'userId': 'ana',
            'leaveBy': '2026-10-10T17:55:00',
            'homeArrivalAt': '2026-10-10T19:30:00',
            'homeArrivalRange': '7:20 PM',
            'homeAfterGuestsArrive': true,
            'stops': [
              {'name': 'Padaria', 'arriveBy': '2026-10-10T18:10:00'},
              {'name': 'Casa', 'arriveBy': '2026-10-10T19:30:00'},
            ],
            'plannedStops': [
              {'name': 'Padaria', 'droppedWhenDelivered': true},
            ],
            'notes': ['Trânsito pesado.'],
            'itinerary': <Object?>[],
          },
        ]
        ..inboxItems = [
          {
            'at': '2026-10-10T17:35:00',
            'title': 'Marco mudou o jantar',
            'userId': 'ana',
            'from': 'marco',
          },
        ];
    });

    test('lists what just happened', () {
      final recent = _summaries(feed.forUser('ana')['recent']);

      expect(recent, contains('O forno chega a 200 °C'));
      expect(recent, contains('Entrega · bolo'));
      expect(recent, contains('Pediu um horário mais tarde'));
      expect(recent, contains('Marco mudou o jantar'));
      expect(
        recent.any(
          (s) =>
              s.contains('chega em casa depois da chegada das visitas. Trânsito') &&
              s.contains('A parada Padaria é a causa'),
        ),
        isTrue,
      );
      expect(
        recent.where((s) => s.startsWith('O bolo foi entregue')),
        hasLength(1),
      );
    });

    test('leads with the courier at the door', () {
      final recent = (feed.forUser('ana')['recent']! as List<dynamic>)
          .cast<Map<String, Object?>>();

      final arrival = recent.singleWhere(
        (m) => (m['summary']! as String).contains('porta da frente'),
      );
      expect(arrival['urgent'], isTrue);
    });

    test('lists what is coming up', () {
      final next = _summaries(feed.forUser('ana')['next']);

      expect(
        next,
        contains('O assado está pronto'),
      );
      expect(
        next.any(
          (s) =>
              s.startsWith(
                'Itinerário de Ana: sair às 5:55 PM, Padaria 6:10 PM',
              ) &&
              s.endsWith('Casa 7:20 PM'),
        ),
        isTrue,
      );
    });

    test('tracks a pending order on every screen', () {
      source.orders.first['status'] = 'pending';
      source.orders.first['statusLabel'] = 'Waiting';
      source.now = DateTime.utc(2026, 10, 10, 16, 45);

      final recent = _summaries(feed.forUser('ana')['recent']);

      expect(recent.any((s) => s.contains('está pending')), isTrue);
    });

    test('tracks an order on the road', () {
      source.orders.first
        ..['status'] = 'out_for_delivery'
        ..['progressPercent'] = 40;
      source.now = DateTime.utc(2026, 10, 10, 17, 30);

      final recent = _summaries(feed.forUser('ana')['recent']);

      expect(
        recent.any((s) => s.contains('está a caminho, 40% do trajeto')),
        isTrue,
      );
    });
  });
}
