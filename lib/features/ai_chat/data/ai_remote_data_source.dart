import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../../ai_chat/domain/entities/ai_message.dart';
import '../../ai_chat/domain/repositories/ai_repository.dart';

class AiRemoteDataSource implements AiRepository {
  AiRemoteDataSource({
    required this.client,
    required this.apiKey,
  });

  final http.Client client;
  final String apiKey;

  @override
  Future<AiMessage> askAI({required String prompt, String? wordContext}) async {
    final requestBody = {
      'contents': [
        {
          'role': 'user',
          'parts': [
            {
              'text': [
                if (wordContext != null && wordContext.isNotEmpty)
                  'Context word: $wordContext',
                prompt,
              ].where((element) => element.isNotEmpty).join('\n\n'),
            },
          ],
        }
      ]
    };

    final response = await client.post(
      Uri.parse('${AppConfig.geminiEndpoint}?key=$apiKey'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List<dynamic>?;
      final content = candidates != null && candidates.isNotEmpty
          ? candidates.first['content'] as Map<String, dynamic>?
          : null;
      final parts = content != null ? content['parts'] as List<dynamic>? : null;
      final text = parts != null && parts.isNotEmpty
          ? (parts.first['text'] as String? ?? '')
          : '';

      return AiMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text.isEmpty ? 'Xin lỗi, mình chưa có câu trả lời.' : text,
        isUser: false,
      );
    }

    throw Exception('Failed to contact AI: ${response.statusCode}');
  }
}
