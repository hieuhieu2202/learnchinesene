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
    if (initialContext != null && initialContext!.isNotEmpty) {
      messages.add(AiMessage(
        id: 'context',
        text: 'Bạn đang hỏi về: $initialContext',
        isUser: false,
      ));
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    final userMessage = AiMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
    );
    messages.add(userMessage);

    isLoading.value = true;
    try {
      final response = await askAI(AskAiParams(
        prompt: text,
        wordContext: initialContext,
      ));
      messages.add(response);
    } finally {
      isLoading.value = false;
    }
  }
}
