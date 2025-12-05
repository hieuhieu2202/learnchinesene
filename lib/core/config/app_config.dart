class AppConfig {
  AppConfig._();

  static const geminiModel = 'gemini-2.0-flash';
  static const geminiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent';

  static const _missingKeySentinel = '<YOUR_GEMINI_API_KEY>';
  static const defaultGeminiApiKey = _missingKeySentinel;

  static const geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: defaultGeminiApiKey,
  );

  static bool isGeminiKeyMissing(String key) =>
      key.trim().isEmpty || key.trim() == _missingKeySentinel;
}
