import 'package:home_backend/data/mock_database.dart';
import 'package:home_backend/scenario/database_feed_source.dart';
import 'package:home_backend/scenario/scenario_world.dart';
import 'package:home_backend/tools/agent_tool.dart';
import 'package:home_backend/tools/tool_args.dart';
import 'package:home_timeline/home_timeline.dart';

/// A tool that returns one user's bakery orders.
AgentTool bakeryOrdersTool(MockDatabase database) {
  return AgentTool(
    name: 'get_bakery_orders',
    description:
        'Devolve os pedidos de padaria de um usuário, como a entrega do '
        'bolo, com o status (pending, confirmed ou delivered), quando foi '
        'confirmado e o horário previsto da entrega, além das mensagens '
        'enviadas à padaria. O status segue a hora atual.',
    inputSchema: userIdInputSchema,
    onCall: (args) => database.bakeryFor(requiredUserId(args)),
  );
}

/// A tool that returns what just happened and what is coming up.
///
/// This is what a screen is ranked by: the most recent thing that happened and
/// the next thing to do decide which cards lead.
AgentTool homeActivityTool(MockDatabase database) {
  final feed = ActivityFeed(DatabaseFeedSource(database));
  return AgentTool(
    name: 'get_home_activity',
    description:
        'Devolve o que acabou de acontecer (`recent`, do mais novo para o '
        'mais velho, os últimos 30 minutos) e o que vem a seguir (`next`, do '
        'mais cedo para o mais tarde, as próximas 2 horas) para um usuário, '
        'na hora atual. Cada momento tem um horário, minutesAgo ou '
        'inMinutes, um kind (plan, oven, bakery, trip, calendar, doorbell, '
        'change ou inbox), um summary e, quando é sobre algo, o deviceId ou '
        'o stepId do plano que aponta. Chame-a primeiro para decidir quais '
        'cards abrem a tela.',
    inputSchema: userIdInputSchema,
    onCall: (args) => feed.forUser(requiredUserId(args)),
  );
}

/// A tool that moves the guests' arrival, and with it the whole dinner plan.
///
/// One call changes the calendar, the recipe plan and the oven schedule, tells
/// the bakery, and replans Paulino's route. The result lists each of those as
/// an effect. The model should read the data again before it describes the day.
AgentTool rescheduleGuestArrivalTool(ScenarioWorld world) {
  return AgentTool(
    name: 'reschedule_guest_arrival',
    description:
        'Move a hora de chegada das visitas e move tudo que depende dela na '
        'mesma proporção: o evento do calendário, todos os passos do plano '
        'da receita, os horários de preaquecer e assar do forno, e a padaria '
        'é avisada. A rota do Paulino é replanejada também. Use quando as '
        'visitas chegam mais cedo ou mais tarde, por exemplo "as visitas '
        'chegam uma hora mais cedo" é shift_minutes -60. Dê exatamente um de '
        'shift_minutes (negativo é mais cedo) ou new_arrival. Passe '
        'requested_by, o usuário que pede, para que as outras pessoas a quem '
        'o jantar está designado sejam avisadas na caixa de entrada do que '
        'mudou. Devolve toda mudança que fez, notificações incluídas. Leia '
        'os dados de novo antes de descrever o resultado.',
    inputSchema: const {
      'type': 'object',
      'properties': {
        'shift_minutes': {
          'type': 'integer',
          'description':
              'Minutos para mover a chegada, negativo para mais cedo.',
        },
        'new_arrival': {
          'type': 'string',
          'description':
              'A nova chegada como HH:mm, 24 horas, por exemplo 18:00.',
        },
        'requested_by': {
          'type': 'string',
          'description': 'O usuário que pede, por exemplo "palmira".',
        },
      },
    },
    onCall: (args) {
      final result = world.planner.moveGuests(
        arrival: args['new_arrival'] as String?,
        shiftMinutes: (args['shift_minutes'] as num?)?.toInt(),
        requestedBy: args['requested_by'] as String?,
      );
      return result;
    },
  );
}

/// A tool that programmes the oven.
AgentTool scheduleOvenTool(ScenarioWorld world) {
  return AgentTool(
    name: 'schedule_oven',
    description:
        'Define quando o forno preaquece e quando o assado vai ao forno, '
        'como HH:mm em 24 horas. O forno confirma a nova programação e '
        'reporta a hora que tinha antes. Deixe um campo de fora para '
        'mantê-lo. Use para mover só o forno; use reschedule_guest_arrival '
        'quando as visitas se movem.',
    inputSchema: const {
      'type': 'object',
      'properties': {
        'preheat_start': {'type': 'string', 'description': 'HH:mm'},
        'roast_in': {'type': 'string', 'description': 'HH:mm'},
      },
    },
    onCall: (args) {
      final result = world.oven.schedule(
        preheatStart: args['preheat_start'] as String?,
        roastIn: args['roast_in'] as String?,
      );
      world.reconcile();
      return result;
    },
  );
}

/// A tool that asks the bakery to deliver the cake.
AgentTool requestBakeryDeliveryTool(ScenarioWorld world) {
  return AgentTool(
    name: 'request_bakery_delivery',
    description:
        'Pede à padaria que entregue o bolo em casa em vez de alguém buscá-lo. '
        'Só a pessoa a quem a retirada do bolo está designada (Paulino) pode '
        'pedir. O pedido começa pending e a padaria o confirma um minuto '
        'depois. O entregador sai em um dos horários fixos da padaria '
        '(`slot`, HH:mm, padrão o horário padrão da padaria) e a viagem leva '
        'sempre a mesma duração fixa, então a previsão de chegada é o '
        'horário mais essa duração. Depois de confirmado, a retirada sai do '
        'calendário e da rota do usuário, e seus itens de caixa de entrada '
        'são marcados como lidos. Leia get_bakery_orders para o status.',
    inputSchema: {
      'type': 'object',
      'properties': {
        ...(userIdInputSchema['properties']! as Map<String, dynamic>),
        'slot': {
          'type': 'string',
          'description':
              'O horário de saída do entregador, HH:mm, 24 horas, um dos '
              'horários de entrega que a padaria oferece. Omita para o '
              'padrão.',
        },
      },
      'required': ['user_id'],
    },
    onCall: (args) {
      final userId = requiredUserId(args);
      final slot = args['slot'];
      final result = world.bakery.requestDelivery(
        userId,
        slot: slot is String && slot.isNotEmpty ? slot : null,
      );
      world.inbox.markRead(userId);
      if (result['action'] == 'requested') {
        world.notifyDeliveryRequested(userId);
      }
      world.reconcile();
      return result;
    },
  );
}
