import 'api_keys.dart';

class AppConfig {
  AppConfig._();

  static const geminiModel = 'gemini-2.5-flash-lite';
  static const geminiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent';

  // ⭐ Lấy API key từ file api_keys.dart (không commit lên git)
  static const geminiApiKey = ApiKeys.geminiApiKey;
}
