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

    final rawPrompt = bootPrompt?.trim();
    if (rawPrompt == null || rawPrompt.isEmpty) {
      _bootPromptSent = true;
      return;
    }
    final prompt = rawPrompt;

    if (messages.any((message) => message.isUser)) {
      _bootPromptSent = true;
      return;
    }
    _bootPromptSent = true;

    final display = (bootDisplayText ??
            (bootWordContext != null && bootWordContext!.trim().isNotEmpty
                ? 'Giải thích giúp mình về ${bootWordContext!.trim()} nhé!'
                : prompt))
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
    } catch (error) {
      messages.add(
        AiMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: _friendlyErrorText(error),
          isUser: false,
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  String _friendlyErrorText(Object error) {
    final message = error.toString();
    if (message.contains('429')) {
      return 'Hán Ngữ Bot đang tạm quá tải (429). Vui lòng thử lại sau hoặc cấu hình GEMINI_API_KEY của riêng bạn để tránh giới hạn.';
    }
    return 'Xin lỗi, Hán Ngữ Bot đang gặp sự cố: $message';
  }
}
