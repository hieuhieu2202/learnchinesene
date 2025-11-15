import 'dart:async';

import 'package:get/get.dart';

import '../../domain/entities/ai_message.dart';
import '../../domain/usecases/ask_ai.dart';

class AiChatController extends GetxController {
  AiChatController({
    required this.askAI,
    this.bootPrompt,
    this.bootDisplayText,
    this.bootWordContext,
  });

  final AskAI askAI;
  final String? bootPrompt;
  final String? bootDisplayText;
  final String? bootWordContext;

  final messages = <AiMessage>[].obs;
  final isLoading = false.obs;
  bool _bootPromptSent = false;

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
    Future.microtask(_triggerBootPromptIfNeeded);
  }

  Future<void> sendMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return Future.value();
    }
    return _ask(
      userText: trimmed,
      promptOverride: trimmed,
    );
  }

  Future<void> _triggerBootPromptIfNeeded() async {
    if (_bootPromptSent) return;
    if (messages.any((message) => message.isUser)) {
      _bootPromptSent = true;
      return;
    }
    _bootPromptSent = true;

    final prompt = (bootPrompt ??
            'Gợi ý giúp mình nên luyện những gì trong tiếng Trung hôm nay với các ví dụ cụ thể nhé.')
        .trim();
    if (prompt.isEmpty) return;

    final display = (bootDisplayText ??
            (bootWordContext != null && bootWordContext!.trim().isNotEmpty
                ? 'Giải thích giúp mình về ${bootWordContext!.trim()} nhé!'
                : 'Gợi ý luyện tập tiếng Trung hôm nay nhé!'))
        .trim();

    await _ask(
      userText: display,
      promptOverride: prompt,
    );
  }

  Future<void> _ask({
    required String userText,
    required String promptOverride,
  }) async {
    final prompt = promptOverride.trim();
    if (prompt.isEmpty) return;

    if (userText.isNotEmpty) {
      messages.add(
        AiMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: userText,
          isUser: true,
        ),
      );
    }

    isLoading.value = true;
    try {
      final response = await askAI(
        AskAiParams(
          prompt: prompt,
          wordContext: bootWordContext,
        ),
      );
      messages.add(response);
    } finally {
      isLoading.value = false;
    }
  }
}
