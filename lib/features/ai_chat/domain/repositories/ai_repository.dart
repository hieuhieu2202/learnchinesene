import '../entities/ai_message.dart';

abstract class AiRepository {
  Future<AiMessage> askAI({
    required String prompt,
    String? wordContext,
  });
}
