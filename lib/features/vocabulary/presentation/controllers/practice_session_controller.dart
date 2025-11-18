import 'dart:math';

import 'package:get/get.dart' hide Progress;
import '../../domain/entities/practice_models.dart';
import '../../domain/entities/progress_entity.dart';
import '../../domain/entities/word.dart';
import '../../domain/usecases/get_examples_by_word.dart';
import '../../domain/usecases/get_progress_for_word.dart';
import '../../domain/usecases/update_progress_after_quiz.dart';

class PracticeSessionController extends GetxController {
  PracticeSessionController({
    required this.words,
    required this.getExamplesByWord,
    required this.getProgressForWord,
    required this.updateProgressAfterQuiz,
    this.maxWords = 5,
  });

  final List<Word> words;
  final GetExamplesByWord getExamplesByWord;
  final GetProgressForWord getProgressForWord;
  final UpdateProgressAfterQuiz updateProgressAfterQuiz;
  final int maxWords;

  final isLoading = true.obs;
  final isFinished = false.obs;
  final currentIndex = 0.obs;
  final score = 0.obs;
  final currentExercise = Rx<SentenceExercise?>(null);
  final results = <ExerciseResult>[].obs;
  final process = Rx<UnitPracticeProcess?>(null);

  final Map<int, Progress> _progressCache = {};
  final Map<int, List<BaseSentence>> _sentenceCache = {};
  final Map<int, Word> _wordLookup = {};

  bool _isHandlingResult = false;

  @override
  void onInit() {
    super.onInit();
    for (final word in words) {
      _wordLookup[word.id] = word;
    }
    _prepareProcess();
  }

  Word? get currentWord {
    final exercise = currentExercise.value;
    if (exercise == null) {
      return null;
    }
    return _wordLookup[exercise.sentence.mainWordId];
  }

  int get totalExercises => process.value?.exercises.length ?? 0;

  Future<void> restart() => _prepareProcess();

  Future<bool> submitTypedAnswer(String input) async {
    final exercise = currentExercise.value;
    if (exercise == null || _isHandlingResult) {
      return false;
    }

    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return false;
    }

    final isCorrect = _isAnswerCorrect(exercise, trimmed);
    if (!isCorrect) {
      return false;
    }

    await _finalizeExercise(
      exercise: exercise,
      userInput: input,
      correct: true,
      advance: true,
    );
    return true;
  }

  Future<void> markWrong({bool advance = true}) async {
    final exercise = currentExercise.value;
    if (exercise == null || _isHandlingResult) {
      return;
    }

    await _finalizeExercise(
      exercise: exercise,
      userInput: '',
      correct: false,
      advance: advance,
    );
  }

  Future<void> skipCurrent() async {
    await markWrong(advance: true);
  }

  Future<void> _prepareProcess() async {
    if (_isHandlingResult) {
      return;
    }

    isLoading.value = true;
    isFinished.value = false;
    currentIndex.value = 0;
    currentExercise.value = null;
    score.value = 0;
    results.clear();
    process.value = null;
    _progressCache.clear();
    _sentenceCache.clear();

    if (words.isEmpty) {
      isLoading.value = false;
      isFinished.value = true;
      return;
    }

    final selectedWords = words.take(maxWords).toList();
    final exercises = <SentenceExercise>[];
    final wordIds = <int>[];

    for (final word in selectedWords) {
      wordIds.add(word.id);
      await _loadProgress(word.id);
      final baseSentences = await _loadBaseSentences(word.id);
      final topExamples = baseSentences.take(2);
      for (final base in topExamples) {
        exercises.addAll(_generateExercisesForBaseSentence(base, word));
      }

      final aiSentences = _generateAiSentences(word, baseSentences: baseSentences);
      for (final ai in aiSentences) {
        exercises.addAll(_generateExercisesForAiSentence(ai));
      }
    }

    if (exercises.isEmpty) {
      isLoading.value = false;
      isFinished.value = true;
      return;
    }

    final processModel = UnitPracticeProcess(
      sectionId: selectedWords.first.sectionId,
      wordIds: wordIds,
      exercises: exercises,
    );
    process.value = processModel;
    currentExercise.value = processModel.exercises.first;
    isLoading.value = false;
  }

  Future<void> _finalizeExercise({
    required SentenceExercise exercise,
    required String userInput,
    required bool correct,
    required bool advance,
  }) async {
    if (_isHandlingResult) {
      return;
    }
    _isHandlingResult = true;

    final progress = await _loadProgress(exercise.sentence.mainWordId);
    final newCorrect = progress.correctCount + (correct ? 1 : 0);
    final newWrong = progress.wrongCount + (correct ? 0 : 1);

    final updatedLevel = _calculateNextLevel(
      previousLevel: progress.level,
      correct: correct,
      totalCorrect: newCorrect,
    );

    await updateProgressAfterQuiz(
      UpdateProgressParams(
        progress: progress,
        correctCount: newCorrect,
        wrongCount: newWrong,
        lastPractice: DateTime.now(),
        level: updatedLevel,
        mastered: updatedLevel >= 5,
      ),
    );

    _progressCache[progress.wordId] = progress.copyWith(
      correctCount: newCorrect,
      wrongCount: newWrong,
      level: updatedLevel,
      mastered: updatedLevel >= 5,
      lastPractice: DateTime.now(),
    );

    results.add(
      ExerciseResult(
        exercise: exercise,
        userInput: userInput,
        isCorrect: correct,
        doneAt: DateTime.now(),
      ),
    );

    if (correct) {
      score.value += 1;
    }

    if (advance) {
      _moveNext();
    }

    _isHandlingResult = false;
  }

  Future<Progress> _loadProgress(int wordId) async {
    final cached = _progressCache[wordId];
    if (cached != null) {
      return cached;
    }
    final loaded = await getProgressForWord(wordId);
    if (loaded != null) {
      _progressCache[wordId] = loaded;
      return loaded;
    }
    final created = Progress(
      wordId: wordId,
      correctCount: 0,
      wrongCount: 0,
      lastPractice: null,
      level: 0,
      mastered: false,
    );
    _progressCache[wordId] = created;
    return created;
  }

  Future<List<BaseSentence>> _loadBaseSentences(int wordId) async {
    final cached = _sentenceCache[wordId];
    if (cached != null) {
      return cached;
    }
    final examples = await getExamplesByWord(wordId);
    final base = examples
        .map(
          (example) => BaseSentence(
            id: example.id,
            wordId: example.wordId,
            chinese: example.sentenceCn,
            pinyin: example.sentencePinyin,
            vietnamese: example.sentenceVi,
          ),
        )
        .toList();
    _sentenceCache[wordId] = base;
    return base;
  }

  List<SentenceExercise> _generateExercisesForBaseSentence(
    BaseSentence base,
    Word word,
  ) {
    final practiceSentence = PracticeSentence(
      id: 'db-${base.id}',
      baseExampleId: base.id,
      mainWordId: base.wordId,
      chinese: base.chinese,
      pinyin: base.pinyin,
      vietnamese: base.vietnamese,
      isFromAI: false,
    );

    return [
      SentenceExercise(
        type: ExerciseType.typeFromVietnamese,
        sentence: practiceSentence,
        hintVietnamese: base.vietnamese,
        hintPinyin: base.pinyin,
        correctAnswer: base.chinese,
      ),
      SentenceExercise(
        type: ExerciseType.typeFromPinyin,
        sentence: practiceSentence,
        hintVietnamese: base.vietnamese,
        hintPinyin: base.pinyin,
        correctAnswer: base.chinese,
      ),
      SentenceExercise(
        type: ExerciseType.typeMissingWord,
        sentence: practiceSentence,
        hiddenWord: word.word,
        hintVietnamese: base.vietnamese,
        hintPinyin: base.pinyin,
        correctAnswer: word.word,
      ),
      SentenceExercise(
        type: ExerciseType.typeFullSentenceCopy,
        sentence: practiceSentence,
        hintVietnamese: base.vietnamese,
        hintPinyin: base.pinyin,
        correctAnswer: base.chinese,
      ),
    ];
  }

  List<PracticeSentence> _generateAiSentences(
    Word word, {
    required List<BaseSentence> baseSentences,
  }) {
    final existingTexts = baseSentences.map((s) => s.chinese).toSet();
    final pinyinWord = _normalizePinyin(word.transliteration);
    final suggestions = <PracticeSentence>[];

    final templates = [
      _AiTemplate(
        chinese: '我们每天都需要${word.word}。',
        pinyin: 'wǒmen měitiān dōu xūyào $pinyinWord.',
        vietnamese: 'Chúng ta cần ${word.translation} mỗi ngày.',
      ),
      _AiTemplate(
        chinese: '他对${word.word}很感兴趣。',
        pinyin: 'tā duì $pinyinWord hěn gǎn xìngqù.',
        vietnamese: 'Anh ấy rất hứng thú với ${word.translation}.',
      ),
    ];

    var index = 0;
    for (final template in templates) {
      final chinese = template.chinese;
      if (existingTexts.contains(chinese)) {
        continue;
      }
      suggestions.add(
        PracticeSentence(
          id: 'ai-${word.id}-${index++}',
          baseExampleId: null,
          mainWordId: word.id,
          chinese: chinese,
          pinyin: template.pinyin,
          vietnamese: template.vietnamese,
          isFromAI: true,
        ),
      );
      if (suggestions.isNotEmpty) {
        break;
      }
    }

    if (suggestions.isEmpty) {
      suggestions.add(
        PracticeSentence(
          id: 'ai-${word.id}-fallback',
          baseExampleId: null,
          mainWordId: word.id,
          chinese: '${word.word}让生活更好。',
          pinyin: '$pinyinWord ràng shēnghuó gèng hǎo.',
          vietnamese: '${word.translation} khiến cuộc sống tốt hơn.',
          isFromAI: true,
        ),
      );
    }

    return suggestions;
  }

  List<SentenceExercise> _generateExercisesForAiSentence(
    PracticeSentence sentence,
  ) {
    return [
      SentenceExercise(
        type: ExerciseType.typeTransformed,
        sentence: sentence,
        hintVietnamese: sentence.vietnamese,
        hintPinyin: sentence.pinyin,
        correctAnswer: sentence.chinese,
      ),
      SentenceExercise(
        type: ExerciseType.typeFullSentenceCopy,
        sentence: sentence,
        hintVietnamese: sentence.vietnamese,
        hintPinyin: sentence.pinyin,
        correctAnswer: sentence.chinese,
      ),
    ];
  }

  String _normalizePinyin(String input) {
    return input.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();
  }

  bool _isAnswerCorrect(SentenceExercise exercise, String input) {
    final normalizedInput = _normalizeForComparison(
      exercise.type,
      input,
    );
    final normalizedAnswer = _normalizeForComparison(
      exercise.type,
      exercise.correctAnswer,
    );
    return normalizedInput == normalizedAnswer;
  }

  String _normalizeForComparison(ExerciseType type, String value) {
    var normalized = value.trim();
    switch (type) {
      case ExerciseType.typeMissingWord:
        normalized = normalized.replaceAll(RegExp(r'\s+'), '');
        break;
      default:
        const punctuationPattern =
            r"""[，,。.?!？！；;：“”"'()（）·…—《》〈〉、:_【】\[\]-]""";
        normalized = normalized
            .replaceAll(RegExp(punctuationPattern), '')
            .replaceAll(RegExp(r'\s+'), '')
            .toLowerCase();
        break;
    }
    return normalized;
  }

  void _moveNext() {
    final processModel = process.value;
    if (processModel == null) {
      return;
    }

    final nextIndex = currentIndex.value + 1;
    if (nextIndex >= processModel.exercises.length) {
      currentExercise.value = null;
      isFinished.value = true;
      _autoCloseAfterFinish();
      return;
    }

    currentIndex.value = nextIndex;
    currentExercise.value = processModel.exercises[nextIndex];
  }

  void _autoCloseAfterFinish() {
    final navigator = Get.key.currentState;
    Future.delayed(const Duration(milliseconds: 400), () {
      if (navigator != null && navigator.canPop()) {
        navigator.pop({
          'results': results.toList(),
          'score': score.value,
          'total': totalExercises,
        });
      }
    });
  }

  int _calculateNextLevel({
    required int previousLevel,
    required bool correct,
    required int totalCorrect,
  }) {
    if (!correct) {
      return max(0, previousLevel - 1);
    }
    if (totalCorrect >= 12) {
      return 5;
    }
    if (totalCorrect >= 8) {
      return max(previousLevel, 4);
    }
    if (totalCorrect >= 5) {
      return max(previousLevel, 3);
    }
    if (totalCorrect >= 3) {
      return max(previousLevel, 2);
    }
    return max(previousLevel, 1);
  }
}

class _AiTemplate {
  const _AiTemplate({
    required this.chinese,
    required this.pinyin,
    required this.vietnamese,
  });

  final String chinese;
  final String pinyin;
  final String vietnamese;
}
