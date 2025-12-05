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
    if (_isMissingApiKey) {
      return AiMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text:
            'Chưa cấu hình khóa Gemini. Thêm --dart-define=GEMINI_API_KEY=... khi build để kích hoạt AI.',
        isUser: false,
      );
    }
    final instruction = '''
Bạn là "Hán Ngữ Bot", một trợ lý học tiếng Trung thân thiện.
Nhiệm vụ của bạn:
- Chỉ trả lời các câu hỏi liên quan tới tiếng Trung, từ vựng, ngữ pháp, văn hoá hoặc học tiếng Trung.
- Nếu câu hỏi nằm ngoài phạm vi đó, hãy từ chối nhẹ nhàng bằng tiếng Việt và gợi ý người dùng hỏi về tiếng Trung.
- Khi trả lời hãy ưu tiên giải thích bằng tiếng Việt, kèm chữ Hán và pinyin khi cần thiết.
- Đưa ví dụ, mẹo luyện tập hoặc gợi ý câu mẫu bằng tiếng Trung khi phù hợp.
''';

    final userPrompt = <String>[
      if (wordContext != null && wordContext.isNotEmpty)
        'Từ trọng tâm: $wordContext',
      prompt,
    ].where((element) => element.isNotEmpty).join('\n\n');

    final requestBody = {
      'systemInstruction': {
        'role': 'system',
        'parts': [
          {
            'text': instruction,
          }
        ],
      },
      'contents': [
        {
          'role': 'user',
          'parts': [
            {
              'text': userPrompt,
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
      List<dynamic>? partList;
      if (candidates != null && candidates.isNotEmpty) {
        final candidate = candidates.first;
        if (candidate is Map<String, dynamic>) {
          final content = candidate['content'];
          if (content is Map<String, dynamic>) {
            partList = content['parts'] as List<dynamic>?;
          }
        }
      }
      final text = partList != null && partList.isNotEmpty
          ? (partList.first['text'] as String? ?? '')
          : '';

      return AiMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text.isEmpty ? 'Xin lỗi, mình chưa có câu trả lời.' : text,
        isUser: false,
      );
    }

    final error = _readError(response.body);
    throw Exception('Failed to contact AI: ${response.statusCode} $error');
  }

  bool get _isMissingApiKey => AppConfig.isGeminiKeyMissing(apiKey);

  String _readError(String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final error = decoded['error'];
      if (error is Map<String, dynamic>) {
        return error['message'] as String? ?? '';
      }
      return error == null ? '' : error.toString();
    } catch (_) {
      return '';
    }
  }
}
