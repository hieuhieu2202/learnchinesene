import 'package:get/get.dart';

import '../../../domain/entities/progress_entity.dart';
import '../../../domain/entities/word.dart';
import '../../../domain/usecases/get_progress_for_word.dart';
import '../../../domain/usecases/update_progress_after_quiz.dart';

enum PracticeMode {
  flashcard,
  flashcardReverse,
  listening,
  pinyin,
  fillBlank,
  reading,
  matching,
}

class PracticeQuestion {
  PracticeQuestion({
    required this.word,
    required this.prompt,
    required this.answer,
  });

  final Word word;
  final String prompt;
  final String answer;
}

class PracticeSessionController extends GetxController {
  PracticeSessionController({
    required this.words,
    required this.mode,
    required this.getProgressForWord,
    required this.updateProgressAfterQuiz,
  });

  final List<Word> words;
  final PracticeMode mode;
  final GetProgressForWord getProgressForWord;
  final UpdateProgressAfterQuiz updateProgressAfterQuiz;

  final questions = <PracticeQuestion>[];
  final currentIndex = 0.obs;
  final score = 0.obs;
  final isFinished = false.obs;

  final Map<int, Progress> _progressCache = {};

  PracticeQuestion? get currentQuestion =>
      currentIndex.value < questions.length ? questions[currentIndex.value] : null;

  @override
  void onInit() {
    super.onInit();
    _prepareQuestions();
  }

  Future<void> markCorrect() async {
    score.value++;
    await _updateProgress(correct: true);
    _moveNext();
  }

  Future<void> markWrong() async {
    await _updateProgress(correct: false);
    _moveNext();
  }

  void _prepareQuestions() {
    for (final word in words) {
      questions.add(PracticeQuestion(
        word: word,
        prompt: _buildPrompt(word),
        answer: _buildAnswer(word),
      ));
    }
  }

  String _buildPrompt(Word word) {
    switch (mode) {
      case PracticeMode.flashcard:
        return word.word;
      case PracticeMode.flashcardReverse:
        return word.translation;
      case PracticeMode.listening:
        return 'Nghe và đoán nghĩa cho: ${word.word}';
      case PracticeMode.pinyin:
        return 'Điền pinyin cho: ${word.word}';
      case PracticeMode.fillBlank:
        return 'Điền từ vào chỗ trống: ____ (${word.translation})';
      case PracticeMode.reading:
        return 'Đọc to: ${word.word}';
      case PracticeMode.matching:
        return 'Ghép nghĩa cho ${word.word}';
    }
  }

  String _buildAnswer(Word word) {
    switch (mode) {
      case PracticeMode.flashcard:
        return word.translation;
      case PracticeMode.flashcardReverse:
        return word.word;
      case PracticeMode.listening:
        return word.translation;
      case PracticeMode.pinyin:
        return word.transliteration;
      case PracticeMode.fillBlank:
        return word.word;
      case PracticeMode.reading:
        return word.transliteration;
      case PracticeMode.matching:
        return word.translation;
    }
  }

  Future<void> _updateProgress({required bool correct}) async {
    final current = currentQuestion;
    if (current == null) return;

    final wordId = current.word.id;
    var progress = _progressCache[wordId];

    progress ??= await getProgressForWord(wordId) ??
        Progress(
          wordId: wordId,
          correctCount: 0,
          wrongCount: 0,
          lastPractice: null,
          level: 0,
          mastered: false,
        );

    progress = progress.copyWith(
      correctCount: correct ? progress.correctCount + 1 : progress.correctCount,
      wrongCount: correct ? progress.wrongCount : progress.wrongCount + 1,
      mastered: correct ? (progress.correctCount + 1) >= 5 : false,
    );

    _progressCache[wordId] = progress;

    await updateProgressAfterQuiz(
      UpdateProgressParams(
        progress: progress,
        lastPractice: DateTime.now(),
      ),
    );
  }

  void _moveNext() {
    if (currentIndex.value + 1 >= questions.length) {
      isFinished.value = true;
    } else {
      currentIndex.value++;
    }
  }
}
