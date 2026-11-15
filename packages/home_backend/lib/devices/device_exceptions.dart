/// {@template device_command_exception}
/// A command the device state machine could not apply.
/// {@endtemplate}
///
/// [message] is written for people: the `/action` route sends it to the client
/// as is, and a model calling a write tool gets it back and can recover. It is
/// 60 characters or fewer, in plain words, with no codes.
sealed class DeviceCommandException implements Exception {
  /// {@macro device_command_exception}
  const DeviceCommandException(this.message);

  /// {@template user_safe_reason}
  /// The short, user-safe reason.
  /// {@endtemplate}
  final String message;

  @override
  String toString() => message;
}

/// {@template device_not_found}
/// The device, scene, list or list item named by a command does not exist.
/// Maps to `404`.
/// {@endtemplate}
class DeviceNotFound extends DeviceCommandException {
  /// {@macro device_not_found}
  ///
  /// Creates a [DeviceNotFound] with a ready-made [message].
  const DeviceNotFound(super.message);

  /// {@macro device_not_found}
  ///
  /// An unknown device, scene or list [id]: "Couldn't find the oven."
  ///
  /// The id is only echoed when it is made of plain characters, so a hostile
  /// value never reaches the client.
  factory DeviceNotFound.forId(String id, {String kind = ''}) {
    final plain = id.replaceAll(RegExp('[_-]+'), ' ').trim();
    final safe = RegExp(r'^[A-Za-z0-9 ]{1,30}$').hasMatch(plain);
    final what = safe ? plain.toLowerCase() : 'isso';
    final suffix = kind.isEmpty ? '' : ' ($kind)';
    return DeviceNotFound(
      safe ? 'Não encontrei "$what"$suffix.' : 'Não encontrei isso$suffix.',
    );
  }
}

/// {@template command_rejected}
/// The command is valid but the device cannot do it: offline, in the wrong
/// state, or it has no such capability. Maps to `409`.
/// {@endtemplate}
class CommandRejected extends DeviceCommandException {
  /// {@macro command_rejected}
  ///
  /// Creates a [CommandRejected] with a ready-made [message].
  const CommandRejected(super.message);

  /// {@macro command_rejected}
  ///
  /// "The oven can't do that right now."
  factory CommandRejected.cannot(String deviceName) =>
      CommandRejected('${_the(deviceName)} não pode fazer isso agora.');

  /// {@macro command_rejected}
  ///
  /// "The oven is offline."
  factory CommandRejected.offline(String deviceName) =>
      CommandRejected('${_the(deviceName)} está offline.');
}

String _the(String name) {
  final lower = name.toLowerCase();
  const articles = {
    'forno': 'o',
    'geladeira': 'a',
    'termostato': 'o',
    'carro': 'o',
    'fechadura': 'a',
    'luzes': 'as',
    'caixa de som': 'a',
    'campainha': 'a',
    'cena': 'a',
    'garagem': 'a',
    'cafeteira': 'a',
    'coifa': 'a',
    'lava-louças': 'a',
    'persianas': 'as',
    'carregador de ev': 'o',
    'porta da garagem': 'a',
    'fechadura da porta da frente': 'a',
    'medidor de energia': 'o',
    'luminária de mesa': 'a',
    'luzes de pendente': 'as',
    'luzes da mesa': 'as',
  };
  final article = articles[lower] ?? 'o';
  final capitalized =
      article[0].toUpperCase() + article.substring(1);
  return '$capitalized $lower';
}

/// "$deviceName" com o artigo certo, para as mensagens do estado.
String artigo(String name) => _the(name);
