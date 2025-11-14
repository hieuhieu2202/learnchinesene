class AppConfig {
  AppConfig._();

  static const geminiModel = 'gemini-2.0-flash';
  static const geminiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent';
}
