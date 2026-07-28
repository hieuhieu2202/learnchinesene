
import '../../../../core/usecase/usecase.dart';
import '../entities/ai_message.dart';
import '../repositories/ai_repository.dart';

class AskAIVer1Ne extends UseCaseVer1Ne<AiMessage, AskAiParams> {
  AskAIVer1Ne(this.repository);

  final AiRepository repository;

  @override
  Future<AiMessage> call(AskAiParams params) {
    return repository.askAI(
      prompt: params.prompt,
      wordContext: params.wordContext,
    );
  }
}

@Deprecated('Use AskAIVer1Ne')
typedef AskAI = AskAIVer1Ne;

class AskAiParams {
  const AskAiParams({
    required this.prompt,
    this.wordContext,
  });

  final String prompt;
  final String? wordContext;
}
