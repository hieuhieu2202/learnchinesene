import 'package:get/get.dart';

import '../../domain/entities/ai_message.dart';
import '../../domain/usecases/ask_ai.dart';

class AiChatController extends GetxController {
  AiChatController({
    required this.askAI,
    this.initialContext,
  });

  final AskAI askAI;
  final String? initialContext;

  final messages = <AiMessage>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    messages.add(
      const AiMessage(
        id: 'intro',
        text:
            'Xin chào! Mình là Hán Ngữ Bot – trợ lý dành cho các câu hỏi về tiếng Trung. Hãy hỏi mình về từ vựng, ngữ pháp hoặc cách luyện tập nhé.',
        isUser: false,
      ),
    );
    if (initialContext != null && initialContext!.isNotEmpty) {
      messages.add(AiMessage(
        id: 'context',
        text: 'Bạn đang hỏi về: $initialContext',
        isUser: false,
      ));
    }
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final userMessage = AiMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: trimmed,
      isUser: true,
    );
    messages.add(userMessage);

    isLoading.value = true;
    try {
      final response = await askAI(AskAiParams(
        prompt: trimmed,
        wordContext: initialContext,
      ));
      messages.add(response);
    } finally {
      isLoading.value = false;
    }
  }
}
