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
  typeTransformed,
}

class SentenceExercise {
  const SentenceExercise({
    required this.type,
    required this.sentence,
    required this.correctAnswer,
    this.hiddenWord,
    this.hintVietnamese,
    this.hintPinyin,
  });

  final ExerciseType type;
  final PracticeSentence sentence;
  final String correctAnswer;
  final String? hiddenWord;
  final String? hintVietnamese;
  final String? hintPinyin;
}

class UnitPracticeProcess {
  const UnitPracticeProcess({
    required this.sectionId,
    required this.wordIds,
    required this.exercises,
  });

  final int sectionId;
  final List<int> wordIds;
  final List<SentenceExercise> exercises;
}

class ExerciseResult {
  const ExerciseResult({
    required this.exercise,
    required this.userInput,
    required this.isCorrect,
    required this.doneAt,
  });

  final SentenceExercise exercise;
  final String userInput;
  final bool isCorrect;
  final DateTime doneAt;
}
