import '../../../models/game_question.dart';
import '../../../models/duo_challenge.dart';

class ChallengeAdapters {
  /// Chuyển đổi DuoChallenge raw thành GameQuestion domain model
  static GameQuestion adaptToQuestion(DuoChallenge challenge) {
    List<int> correctIndices = [];
    if (challenge.choicesCorrect != null) {
      for (int i = 0; i < challenge.choicesCorrect!.length; i++) {
        if (challenge.choicesCorrect![i] == 1) {
          correctIndices.add(i);
        }
      }
    }

    return GameQuestion(
      id: challenge.id,
      type: challenge.type,
      prompt: challenge.prompt,
      tts: challenge.tts,
      slowTts: challenge.slowTts,
      choices: challenge.choicesText ?? [],
      correctIndices: correctIndices,
      solutionText: challenge.solutions,
      tokens: challenge.tokensText ?? [],
      hints: challenge.tokensHints ?? [],
      images: challenge.choicesImage ?? [],
    );
  }

  /// Adapt cho câu hỏi trắc nghiệm/chọn đáp án
  static List<GameQuestion> adaptMultipleChoice(List<DuoChallenge> challenges) {
    return challenges.map((c) => adaptToQuestion(c)).toList();
  }

  /// Adapt cho câu hỏi nghe
  static List<GameQuestion> adaptListening(List<DuoChallenge> challenges) {
    return challenges.map((c) {
      final q = adaptToQuestion(c);
      return GameQuestion(
        id: q.id,
        type: q.type,
        prompt: q.prompt ?? 'Nghe và chọn đáp án đúng',
        tts: q.tts,
        slowTts: q.slowTts,
        choices: q.choices,
        correctIndices: q.correctIndices,
        solutionText: q.solutionText,
      );
    }).toList();
  }

  /// Adapt cho câu hỏi dịch & xếp câu
  static List<GameQuestion> adaptSentenceBuilder(List<DuoChallenge> challenges) {
    return challenges.map((c) {
      final q = adaptToQuestion(c);
      List<String> tokensToUse = q.tokens;
      if (tokensToUse.isEmpty) {
        // Fallback: tự tách từ solution hoặc prompt
        final textToSplit = q.solutionText ?? q.prompt ?? '';
        tokensToUse = textToSplit.split(' ').where((w) => w.trim().isNotEmpty).toList();
      }

      return GameQuestion(
        id: q.id,
        type: q.type,
        prompt: q.prompt,
        tts: q.tts,
        choices: List<String>.from(tokensToUse)..shuffle(),
        solutionText: q.solutionText ?? tokensToUse.join(' '),
        tokens: tokensToUse,
      );
    }).toList();
  }
}
