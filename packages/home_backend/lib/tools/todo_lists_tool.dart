import 'package:home_backend/data/mock_database.dart';
import 'package:home_backend/tools/agent_tool.dart';
import 'package:home_backend/tools/tool_args.dart';

/// A tool that returns the to-do lists a user owns or has been shared.
AgentTool todoListsTool(MockDatabase database) {
  return AgentTool(
    name: 'get_todo_lists',
    description:
        'Devolve as listas de tarefas que um usuário possui ou tem '
        'compartilhadas, como a lista de compras: id, title, subtitle, com '
        'quem está compartilhada e itens com id, label, detail e checked. O '
        '`id` da lista e o `id` de cada item são os ids que um ShoppingList '
        'deve usar (`listId`, `items[].id`). Listas não são dados do '
        'Google Home.',
    inputSchema: userIdInputSchema,
    onCall: (args) => database.todosFor(requiredUserId(args)),
  );
}
