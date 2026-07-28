class AppConfigVer1Ne {
  AppConfigVer1Ne._();

  static const geminiModel = 'gemini-3.1-flash-lite';
  static const geminiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent';

  // ⭐ Lấy API key từ biến môi trường khi build, hoặc dùng key mặc định để test
  static const geminiApiKey = String.fromEnvironment('GEMINI_API_KEY',
      defaultValue: 'AQ.Ab8RN6KOH8rhDF7q5hINhm8ytc7rbaxkHTu1EKJH4vGR63s5xw');
}

@Deprecated('Use AppConfigVer1Ne')
typedef AppConfig = AppConfigVer1Ne;
