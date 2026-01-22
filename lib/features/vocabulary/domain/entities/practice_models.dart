class BaseSentence {
  const BaseSentence({
    required this.id,
    required this.wordId,
    required this.chinese,
    required this.pinyin,
    required this.vietnamese,
  });

  final int id;
  final int wordId;
  final String chinese;
  final String pinyin;
  final String vietnamese;
}

class PracticeSentence {
  const PracticeSentence({
    required this.id,
    required this.baseExampleId,
    required this.mainWordId,
    required this.chinese,
    required this.pinyin,
    required this.vietnamese,
    required this.isFromAI,
  });

  final String id;
  final int? baseExampleId;
  final int mainWordId;
  final String chinese;
  final String pinyin;
  final String vietnamese;
  final bool isFromAI;
}

enum ExerciseType {
  typeFromVietnamese,
  typeFromPinyin,
  typeMissingWord,
  typeFullSentenceCopy,
  typeArrangeSentence,
  typeTransformed,
}

abstract class Exercise {
  const Exercise({
    required this.type,
    required this.sentence,
    required this.correctAnswer,
    this.userAnswer,
  });

  final ExerciseType type;
  final PracticeSentence sentence;
  final String correctAnswer;
  final dynamic userAnswer;
}

class SentenceExercise extends Exercise {
  const SentenceExercise({
    required ExerciseType type,
    required PracticeSentence sentence,
    required String correctAnswer,
    dynamic userAnswer,
    this.arrangeSegments,
    this.arrangeOptions,
  }) : super(
          type: type,
          sentence: sentence,
          correctAnswer: correctAnswer,
          userAnswer: userAnswer,
        );

  final List<String>? arrangeSegments;
  final List<String>? arrangeOptions;

  SentenceExercise copyWith({
    List<String>? arrangeSegments,
    List<String>? arrangeOptions,
    dynamic userAnswer,
  }) {
    return SentenceExercise(
      type: type,
      sentence: sentence,
      correctAnswer: correctAnswer,
      userAnswer: userAnswer ?? this.userAnswer,
      arrangeSegments: arrangeSegments ?? this.arrangeSegments,
      arrangeOptions: arrangeOptions ?? this.arrangeOptions,
    );
  }
}

class MissingWordExercise extends Exercise {
  const MissingWordExercise({
    required ExerciseType type,
    required PracticeSentence sentence,
    required String correctAnswer,
    required this.hiddenWord,
    required this.userAnswer,
    this.arrangeOptions,
  }) : super(
          type: type,
          sentence: sentence,
          correctAnswer: correctAnswer,
          userAnswer: userAnswer,
        );

  final String hiddenWord;
  final List<String> userAnswer;
  final List<String>? arrangeOptions;
}

class UnitPracticeProcess {
  const UnitPracticeProcess({
    required this.sectionId,
    required this.wordIds,
    required this.exercises,
  });

  final int sectionId;
  final List<int> wordIds;
  final List<Exercise> exercises;
}

class ExerciseResult {
  const ExerciseResult({
    required this.exercise,
    required this.userInput,
    required this.isCorrect,
    required this.doneAt,
  });

  final Exercise exercise;
  final String userInput;
  final bool isCorrect;
  final DateTime doneAt;
}
