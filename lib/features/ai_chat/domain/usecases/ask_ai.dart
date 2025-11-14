import 'package:learnchinese/core/usecase/usecase.dart';

import '../entities/ai_message.dart';
import '../repositories/ai_repository.dart';

class AskAI extends UseCase<AiMessage, AskAiParams> {
  AskAI(this.repository);

  final AiRepository repository;

  @override
  Future<AiMessage> call(AskAiParams params) {
    return repository.askAI(
      prompt: params.prompt,
      wordContext: params.wordContext,
    );
  }
}

class AskAiParams {
  const AskAiParams({
    required this.prompt,
    this.wordContext,
  });

  final String prompt;
  final String? wordContext;
}
