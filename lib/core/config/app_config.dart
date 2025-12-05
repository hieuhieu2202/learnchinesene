class AppConfig {
  AppConfig._();

  static const geminiModel = 'gemini-2.0-flash';
  static const geminiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent';
  static const placeholderGeminiApiKey = '<YOUR_GEMINI_API_KEY>';
  static const _fallbackGeminiApiKey = placeholderGeminiApiKey;
  static const geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: _fallbackGeminiApiKey,
  );
}
