import 'package:home_backend/data/mock_database.dart';
import 'package:home_backend/tools/agent_tool.dart';
import 'package:home_backend/tools/tool_args.dart';

/// A tool that returns the Google Home data model for one user.
///
/// The result carries the structure, rooms, devices with their trait values,
/// groups and the user's automations. Calendar and trips are
/// not Home data and have their own tools. `room` and `device_type` narrow the
/// devices.
AgentTool googleHomeTool(MockDatabase database) {
  return AgentTool(
    name: 'get_google_home_data',
    description:
        'Devolve o modelo de dados do Google Home da família Rivera como um '
        'usuário o vê: estrutura, cômodos, dispositivos com os valores de '
        'traits, grupos e as automações desse usuário. Todo dispositivo e '
        'automação tem um `id`; cenas são as automations com '
        '`"kind": "scene"`. Esses são os ids que uma tela pode apontar '
        '(o `deviceId` de um DeviceCard, o `sceneId` de um SceneCard, um '
        'alvo de comando). Opcionalmente filtre os dispositivos por cômodo '
        'ou tipo. Calendário e viagens não fazem parte, use as ferramentas '
        'próprias deles.',
    inputSchema: const {
      'type': 'object',
      'properties': {
        'user_id': {
          'type': 'string',
          'description': 'O id do usuário, por exemplo "ana" ou "marco".',
        },
        'room': {
          'type': 'string',
          // ignore: lines_longer_than_80_chars
          'description': 'Id ou nome opcional do cômodo, por exemplo "Cozinha".',
        },
        'device_type': {
          'type': 'string',
          'description':
              'Tipo opcional de dispositivo das Home APIs, por exemplo '
              '"OvenDevice".',
        },
      },
      'required': ['user_id'],
    },
    onCall: (args) {
      return database.homeFor(
        requiredUserId(args),
        room: args['room'] as String?,
        deviceType: args['device_type'] as String?,
      );
    },
  );
}
