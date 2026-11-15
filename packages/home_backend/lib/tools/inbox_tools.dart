import 'package:home_backend/data/mock_database.dart';
import 'package:home_backend/scenario/scenario_world.dart';
import 'package:home_backend/tools/agent_tool.dart';
import 'package:home_backend/tools/tool_args.dart';

/// A tool that returns what other people changed that concerns one user.
AgentTool inboxTool(MockDatabase database) {
  return AgentTool(
    name: 'get_inbox',
    description:
        'Devolve a caixa de entrada da família de um usuário, da mais nova '
        'para a mais velha, com a contagem de itens não lidos. Um item é uma '
        'mudança que outra pessoa fez e que concerne este usuário, como "Ana '
        'mudou o jantar": traz o título, o corpo, quem enviou, quando, se '
        'está lido e, quando uma opção é claramente a melhor para este '
        'usuário, uma `suggestion` ({tool, label, reason}) nomeando a '
        'ferramenta que resolveria o plano dele. Chame antes de montar uma '
        'tela: um item não lido abre a tela, e a sugestão dele vira o card '
        'de alerta ou chip que o usuário pode tocar.',
    inputSchema: userIdInputSchema,
    onCall: (args) => database.inboxFor(requiredUserId(args)),
  );
}

/// A tool that marks inbox items as read.
AgentTool markInboxReadTool(ScenarioWorld world) {
  return AgentTool(
    name: 'mark_inbox_read',
    description:
        'Marca como lidos os itens não lidos da caixa de entrada de um '
        'usuário, ou apenas o nomeado por item_id. Use quando o usuário '
        'dispensa ou já tratou uma notificação. Agir sobre a sugestão dela '
        '(por exemplo pedir à padaria que entregue) a marca como lida por si.',
    inputSchema: const {
      'type': 'object',
      'properties': {
        'user_id': {
          'type': 'string',
          'description': 'A caixa de entrada de quem, por exemplo "marco".',
        },
        'item_id': {
          'type': 'string',
          'description': 'Um item a marcar, por exemplo "inbox_1".',
        },
      },
      'required': ['user_id'],
    },
    onCall: (args) => world.inbox.markRead(
      requiredUserId(args),
      itemId: args['item_id'] as String?,
    ),
  );
}
