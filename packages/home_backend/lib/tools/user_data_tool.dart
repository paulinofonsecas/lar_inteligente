import 'package:home_backend/data/mock_database.dart';
import 'package:home_backend/tools/agent_tool.dart';

/// A tool that returns the household's users.
///
/// With a `user_id` it returns that person's full profile: role, what they care
/// about, what their dashboard leads with and the context signals to read.
/// Without one it lists every user so the model can discover valid ids.
AgentTool userDataTool(MockDatabase database) {
  return AgentTool(
    name: 'get_user_data',
    description:
        'Devolve dados das pessoas da família Rivera. Passe user_id para o '
        'perfil de uma (papel, interesses, o que o painel dela abre, sinais '
        'de contexto). Omita para listar todos os usuários.',
    inputSchema: const {
      'type': 'object',
      'properties': {
        'user_id': {
          'type': 'string',
          'description':
              'O id do usuário, por exemplo "palmira". Omita para listar.',
        },
      },
    },
    onCall: (args) {
      final id = args['user_id'];
      if (id is String && id.isNotEmpty) return database.requireUser(id);
      return {'users': database.listUsers()};
    },
  );
}
