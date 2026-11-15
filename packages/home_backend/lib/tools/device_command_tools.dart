import 'package:home_backend/devices/device_command.dart';
import 'package:home_backend/devices/device_exceptions.dart';
import 'package:home_backend/devices/device_state_machine.dart';
import 'package:home_backend/tools/agent_tool.dart';

/// A tool that changes a device, so a spoken or typed request moves the same
/// state a component press does.
///
/// It calls the [DeviceStateMachine], the only writer of the home data, and
/// returns what changed. A device that does not exist or cannot do the command
/// throws, and the model gets the reason back.
AgentTool runDeviceCommandTool(DeviceStateMachine machine) {
  return AgentTool(
    name: 'run_device_command',
    description:
        'Muda um dispositivo de casa e devolve o que mudou. Use quando o '
        'usuário pedir algo num dispositivo, e leia os dados de novo antes '
        'de descrever o resultado. Comandos: on e off (ligar ou desligar, '
        'acender, armar, abrir ou trancar, conforme o dispositivo), start, '
        'stop, open, close, lock, unlock, add_time '
        '(timer, value em minutos, padrão 5), set_level (value de 0 a 100), '
        'set_temperature (value em °C), up e down (um passo no ajuste '
        'principal). Um comando que encontra o dispositivo já nesse estado '
        'não muda nada.',
    inputSchema: {
      'type': 'object',
      'properties': {
        'device_id': {
          'type': 'string',
          'description': 'O id do dispositivo, por exemplo "oven".',
        },
        'command': {'type': 'string', 'enum': DeviceCommand.wireNames},
        'value': {
          'type': 'number',
          'description':
              'O número que set_level, set_temperature e add_time recebem.',
        },
      },
      'required': ['device_id', 'command'],
    },
    onCall: (args) {
      final command = DeviceCommand.tryParse(args['command']);
      if (command == null) {
        throw CommandRejected(
          'Comando desconhecido. Use um de: '
          '${DeviceCommand.wireNames.join(', ')}.',
        );
      }
      return machine
          .execute(
            _text(args, 'device_id'),
            command,
            value: args['value'] as num?,
          )
          .toJson();
    },
  );
}

/// A tool that starts a scene such as the dinner party scene.
AgentTool runSceneTool(DeviceStateMachine machine) {
  return AgentTool(
    name: 'run_scene',
    description:
        'Inicia uma cena, um grupo nomeado de ajustes de dispositivos como a '
        'cena de jantar, e devolve o que mudou. Cenas são as automations '
        'marcadas kind "scene" nos dados do Google Home.',
    inputSchema: const {
      'type': 'object',
      'properties': {
        'scene_id': {
          'type': 'string',
          'description': 'O id da cena, por exemplo "dinner_party".',
        },
      },
      'required': ['scene_id'],
    },
    onCall: (args) => machine.runScene(_text(args, 'scene_id')).toJson(),
  );
}

/// A tool that ticks or unticks a to-do item.
AgentTool setTodoItemTool(DeviceStateMachine machine) {
  return AgentTool(
    name: 'set_todo_item',
    description:
        'Marca ou desmarca um item de uma lista de tarefas e devolve o que '
        'mudou.',
    inputSchema: const {
      'type': 'object',
      'properties': {
        'item_id': {'type': 'string', 'description': 'O id do item.'},
        'checked': {'type': 'boolean'},
        'list_id': {
          'type': 'string',
          'description': 'Id opcional da lista, por exemplo "shopping".',
        },
      },
      'required': ['item_id', 'checked'],
    },
    onCall: (args) {
      final checked = args['checked'];
      if (checked is! bool) {
        throw const CommandRejected('checked deve ser true ou false.');
      }
      return machine
          .toggleTodo(
            itemId: _text(args, 'item_id'),
            checked: checked,
            listId: args['list_id'] as String?,
          )
          .toJson();
    },
  );
}

String _text(Map<String, dynamic> args, String key) {
  final value = args[key];
  if (value is! String || value.isEmpty) {
    throw CommandRejected('$key é obrigatório.');
  }
  return value;
}
