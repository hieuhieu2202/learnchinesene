class AppConfig {
  AppConfig._();

  static const geminiModel = 'gemini-2.0-flash';
  static const geminiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent';
  static const _fallbackGeminiApiKey =
      'AIzaSyAroBdEnrvFQlLHF3aPe41EihU7R813o-4';
  static const geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: _fallbackGeminiApiKey,
  );
}
