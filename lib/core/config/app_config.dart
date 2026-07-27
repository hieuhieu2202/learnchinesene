class AppConfigVer1Ne {
  AppConfigVer1Ne._();

  static const geminiModel = 'gemini-2.5-flash-lite';
  static const geminiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent';

  // ⭐ Lấy API key từ biến môi trường khi build
  static const geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
}

@Deprecated('Use AppConfigVer1Ne')
typedef AppConfig = AppConfigVer1Ne;
