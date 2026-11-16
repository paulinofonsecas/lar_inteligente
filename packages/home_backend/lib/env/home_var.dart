/// {@template home_var}
/// Declared `HOME_*` environment variables consumed by this server.
/// {@endtemplate}
///
/// There is no API key here. The server holds none: each caller sends their own
/// Gemini key with the request.
enum HomeVar {
  /// Optional Gemini model override.
  llmModel('HOME_LLM_MODEL'),

  /// Where the household's shopping list is kept, `data-store/todos.json` by
  /// default. Point it at a mounted disk on a host with an ephemeral
  /// filesystem.
  todosFile('HOME_TODOS_FILE'),

  /// Comma separated browser origins allowed to call the API, for example
  /// `https://app.example.com`. Optional. When unset no origin is allowed, so
  /// browsers block cross-origin calls.
  corsAllowedOrigins('HOME_CORS_ALLOWED_ORIGINS');

  /// {@macro home_var}
  const HomeVar(this.name);

  /// The environment variable name as it appears in the process environment.
  final String name;
}
