import 'package:home_backend/data/mock_database.dart';

/// The JSON Schema for a tool whose only argument is a required `user_id`.
const userIdInputSchema = <String, dynamic>{
  'type': 'object',
  'properties': {
    'user_id': {
      'type': 'string',
      'description': 'O id do usuário, por exemplo "ana" ou "marco".',
    },
  },
  'required': ['user_id'],
};

/// Reads the required `user_id` from a tool's [args].
///
/// Throws [MockDataNotFound] when it is missing or empty, so the model gets the
/// message back and can retry.
String requiredUserId(Map<String, dynamic> args) {
  final userId = args['user_id'];
  if (userId is! String || userId.isEmpty) {
    throw const MockDataNotFound('user_id is required.');
  }
  return userId;
}
