import 'package:get/get.dart' hide Progress;

import '../../domain/entities/example_sentence.dart';
import '../../domain/entities/progress_entity.dart';
import '../../domain/entities/word.dart';
import '../../domain/usecases/get_examples_by_word.dart';
import '../../domain/usecases/get_progress_for_word.dart';
import '../../domain/usecases/update_progress_after_quiz.dart';

enum PracticeMode {
  flashcard,
  flashcardReverse,
  listening,
  pinyin,
  fillBlank,
  reading,
  matching,
  typingPinyin,
  typingHanzi,
}

class PracticeQuestion {
  PracticeQuestion({
    required this.word,
    required this.prompt,
    required this.answer,
    this.example,
    this.hint,
  });

  final Word word;
  final String prompt;
  final String answer;
  final ExampleSentence? example;
  final String? hint;
}

class PracticeSessionController extends GetxController {
  PracticeSessionController({
    required this.words,
    required this.mode,
    required this.getExamplesByWord,
    required this.getProgressForWord,
    required this.updateProgressAfterQuiz,
  });

  final List<Word> words;
  final PracticeMode mode;
  final GetExamplesByWord getExamplesByWord;
  final GetProgressForWord getProgressForWord;
  final UpdateProgressAfterQuiz updateProgressAfterQuiz;

  final questions = <PracticeQuestion>[];
  final currentIndex = 0.obs;
  final score = 0.obs;
  final isFinished = false.obs;
  final isLoading = true.obs;

  final Map<int, Progress> _progressCache = {};

  PracticeQuestion? get currentQuestion =>
      currentIndex.value < questions.length ? questions[currentIndex.value] : null;

  bool get isTypingMode =>
      mode == PracticeMode.typingPinyin || mode == PracticeMode.typingHanzi;

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

  Future<void> skipCurrent() async {
    await markWrong();
  }

  Future<void> _prepareQuestions() async {
    isLoading.value = true;
    questions.clear();
    currentIndex.value = 0;
    score.value = 0;
    isFinished.value = false;
    _progressCache.clear();

    if (isTypingMode) {
      await _buildTypingQuestions();
    } else {
      for (final word in words) {
        questions.add(PracticeQuestion(
          word: word,
          prompt: _buildPrompt(word),
          answer: _buildAnswer(word),
        ));
      }
    }

    isLoading.value = false;
    if (questions.isEmpty) {
      isFinished.value = true;
    }
  }

  Future<void> _buildTypingQuestions() async {
    for (final word in words) {
      final examples = await getExamplesByWord(word.id);
      for (final example in examples) {
        if (mode == PracticeMode.typingPinyin) {
          questions.add(PracticeQuestion(
            word: word,
            example: example,
            prompt: 'Gõ pinyin cho câu:\n${example.sentenceCn}',
            answer: example.sentencePinyin,
            hint: example.sentenceVi,
          ));
        } else if (mode == PracticeMode.typingHanzi) {
          questions.add(PracticeQuestion(
            word: word,
            example: example,
            prompt: 'Gõ lại câu bằng chữ Hán từ pinyin:\n${example.sentencePinyin}',
            answer: example.sentenceCn,
            hint: example.sentenceVi,
          ));
        }
      }
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
      case PracticeMode.typingPinyin:
      case PracticeMode.typingHanzi:
        return '';
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
      case PracticeMode.typingPinyin:
      case PracticeMode.typingHanzi:
        return '';
    }
  }

  Future<bool> submitTypedAnswer(String input) async {
    if (!isTypingMode) {
      return false;
    }

    final question = currentQuestion;
    if (question == null) {
      return false;
    }

    final normalizedInput = _normalizeInput(input);
    final normalizedAnswer = _normalizeInput(question.answer);

    final isCorrect = normalizedInput == normalizedAnswer;
    if (isCorrect) {
      await markCorrect();
    }
    return isCorrect;
  }

  String _normalizeInput(String value) {
    final trimmed = value.trim();
    final punctuationRemoved =
        trimmed.replaceAll(_punctuationRegex, '');
    switch (mode) {
      case PracticeMode.typingPinyin:
        return punctuationRemoved.replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
      case PracticeMode.typingHanzi:
        return punctuationRemoved.replaceAll(RegExp(r'\s+'), '');
      default:
        return punctuationRemoved;
    }
  }

  static final _punctuationRegex =
      RegExp(r"[，,。\.！!？\?；;：“”\"'()（）·…—-]");

  Future<void> _updateProgress({required bool correct}) async {
    final current = currentQuestion;
    if (current == null) return;

    final wordId = current.word.id;
    var progress = _progressCache[wordId];

    progress ??= await getProgressForWord(wordId) ?? Progress(
      wordId: wordId,
      correctCount: 0,
      wrongCount: 0,
      lastPractice: null,
      level: 0,
      mastered: false,
    );

    final nextCorrect = correct ? progress.correctCount + 1 : progress.correctCount;
    final nextWrong = correct ? progress.wrongCount : progress.wrongCount + 1;

    final updated = progress.copyWith(
      correctCount: nextCorrect,
      wrongCount: nextWrong,
      lastPractice: DateTime.now(),
      mastered: correct ? nextCorrect >= 5 : false,
    );

    _progressCache[wordId] = updated;

    await updateProgressAfterQuiz(
      UpdateProgressParams(
        progress: updated,
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
