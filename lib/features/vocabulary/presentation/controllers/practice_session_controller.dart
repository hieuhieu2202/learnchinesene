import 'dart:math';

import 'package:collection/collection.dart';
import 'package:get/get.dart' hide Progress;
import '../../domain/entities/practice_models.dart';
import '../../domain/entities/progress_entity.dart';
import '../../domain/entities/word.dart';
import '../../domain/repositories/user_stats_repository.dart';
import '../../domain/usecases/add_experience.dart';
import '../../domain/usecases/get_examples_by_word.dart';
import '../../domain/usecases/get_progress_for_word.dart';
import '../../domain/usecases/update_progress_after_quiz.dart';
import 'section_list_controller.dart';
import 'word_list_controller.dart';

class PracticeSessionController extends GetxController {
  PracticeSessionController({
    required this.words,
    required this.getExamplesByWord,
    required this.getProgressForWord,
    required this.updateProgressAfterQuiz,
    required this.addExperienceUseCase,
    required this.userStatsRepository,
    this.maxWords = 5,
  });

  static const _stringListEquality = ListEquality<String>();

  final List<Word> words;
  final GetExamplesByWord getExamplesByWord;
  final GetProgressForWord getProgressForWord;
  final UpdateProgressAfterQuiz updateProgressAfterQuiz;
  final AddExperienceUseCase addExperienceUseCase;
  final UserStatsRepository userStatsRepository;
  final int maxWords;

  final isLoading = true.obs;
  final isFinished = false.obs;
  final currentIndex = 0.obs;
  final currentExercise = Rx<Exercise?>(null);
  final score = 0.obs;
  final expEarned = 0.obs; // ⭐ Theo dõi EXP kiếm được trong bài
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

    if (exercise.type == ExerciseType.typeArrangeSentence) {
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
    final exercises = <Exercise>[];
    final wordIds = <int>[];

    for (final word in selectedWords) {
      wordIds.add(word.id);
      await _loadProgress(word.id);
      final baseSentences = await _loadBaseSentences(word.id);
      // Use all available examples instead of just top 2
      // Remove AI-generated sentences and increase database examples
      for (final base in baseSentences) {
        exercises.addAll(_generateExercisesForBaseSentence(base, word));
      }
    }

    if (exercises.isEmpty) {
      isLoading.value = false;
      isFinished.value = true;
      return;
    }

    // Shuffle exercises để có sự đa dạng trong luyện tập
    // Tránh tình trạng câu giống nhau lặp lại nhiều lần liên tiếp
    exercises.shuffle(Random());

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
    required Exercise exercise,
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

    print('📝 [PRACTICE] Cập nhật progress:');
    print('   Từ ID: ${exercise.sentence.mainWordId}');
    print('   Câu trả lời: ${correct ? "✅ Đúng" : "❌ Sai"}');
    print('   correctCount cũ: ${progress.correctCount}');
    print('   correctCount mới: $newCorrect');
    print('   wrongCount mới: $newWrong');

    final updatedLevel = _calculateNextLevel(
      previousLevel: progress.level,
      correct: correct,
      totalCorrect: newCorrect,
    );

    print('   Level cũ: ${progress.level}');
    print('   Level mới: $updatedLevel');

    // ⭐ Kiểm tra nếu từ này vừa được mastered (level từ < 5 → >= 5)
    final isMastered = updatedLevel >= 5;
    final wasMastered = progress.mastered;

    print('🎯 [PRACTICE] Kiểm tra mastery:');
    print('   📊 Level cũ: ${progress.level}');
    print('   📊 Level mới: $updatedLevel');
    print('   ✨ isMastered: $isMastered');
    print('   ✨ wasMastered: $wasMastered');
    print('   🔥 Sẽ cập nhật streak? ${isMastered && !wasMastered}');

    await updateProgressAfterQuiz(
      UpdateProgressParams(
        progress: progress,
        correctCount: newCorrect,
        wrongCount: newWrong,
        lastPractice: DateTime.now(),
        level: updatedLevel,
        mastered: isMastered,
      ),
    );

    // ⭐ Nếu vừa mastered từ (chưa mastered trước) → Cập nhật streak
    if (isMastered && !wasMastered) {
      print('🔥 [PRACTICE] Từ vừa được mastered, cập nhật streak...');
      await _updateStreakOnWordMastered();
    }

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
      expEarned.value += 1; // ⭐ +1 EXP cho mỗi câu đúng

      // 🎉 Cập nhật EXP vào database ngay lập tức
      try {
        await addExperienceUseCase(
          correctAnswers: 1,
          lessonCompleted: false, // Chỉ tính 1 EXP/câu, không cần hoàn thành
        );
        print('✅ +1 EXP | Tổng: ${expEarned.value}');
      } catch (e) {
        print('❌ Lỗi cập nhật EXP: $e');
      }
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

  List<Exercise> _generateExercisesForBaseSentence(
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
        correctAnswer: base.chinese,
      ),
      SentenceExercise(
        type: ExerciseType.typeFromPinyin,
        sentence: practiceSentence,
        correctAnswer: base.chinese,
      ),
      MissingWordExercise(
        type: ExerciseType.typeMissingWord,
        sentence: practiceSentence,
        correctAnswer: word.word,
        hiddenWord: word.word,
        userAnswer: [], // Truyền đúng kiểu List<String>
      ),
      SentenceExercise(
        type: ExerciseType.typeFullSentenceCopy,
        sentence: practiceSentence,
        correctAnswer: base.chinese,
      ),
      SentenceExercise(
        type: ExerciseType.typeArrangeSentence,
        sentence: practiceSentence,
        correctAnswer: base.chinese,
        arrangeSegments: _splitSentence(base.chinese),
        arrangeOptions: _generateArrangeOptions(_splitSentence(base.chinese)),
      ),
    ];
  }

  List<String> _splitSentence(String sentence) {
    // First, remove all punctuation and special characters.
    final punctuation =
        RegExp(r'[，,。.?!？！；;："""()（）·…—《》〈〉、:_【】\[\]\-' + r"''" + r']');
    final cleaned = sentence.replaceAll(punctuation, '');

    // Split into individual characters (each Chinese character becomes a segment)
    final segments = <String>[];
    for (int i = 0; i < cleaned.length; i++) {
      final char = cleaned[i];
      // Skip whitespace
      if (char.trim().isEmpty) continue;
      segments.add(char);
    }

    return segments;
  }

  List<String> _generateArrangeOptions(List<String> segments) {
    final options = List<String>.from(segments);
    options.shuffle();
    return options;
  }

  Future<void> _generateExercises() async {
    final selectedWords = words.take(maxWords).toList();
    final exercises = <Exercise>[];

    for (final word in selectedWords) {
      final baseSentences = await _loadBaseSentences(word.id);
      for (final base in baseSentences) {
        exercises.addAll(_generateExercisesForBaseSentence(base, word));
      }
    }

    // Shuffle exercises để có sự đa dạng trong luyện tập
    // Tránh tình trạng câu giống nhau lặp lại nhiều lần liên tiếp
    exercises.shuffle(Random());

    final processModel = UnitPracticeProcess(
      sectionId: selectedWords.first.sectionId,
      wordIds: selectedWords.map((word) => word.id).toList(),
      exercises: exercises,
    );

    process.value = processModel;
    currentExercise.value = processModel.exercises.first;
  }

  Future<bool> submitArrangeAnswer(List<String> orderedSegments) async {
    final exercise = currentExercise.value;
    if (exercise == null || _isHandlingResult) {
      return false;
    }
    if (exercise.type != ExerciseType.typeArrangeSentence) {
      return false;
    }
    if (orderedSegments.isEmpty) {
      return false;
    }

    final target = (exercise as SentenceExercise).arrangeSegments ??
        _splitSentence(exercise.correctAnswer);
    final isCorrect = _stringListEquality.equals(orderedSegments, target);
    if (!isCorrect) {
      return false;
    }

    await _finalizeExercise(
      exercise: exercise,
      userInput: orderedSegments.join(''), // Join without space for Chinese
      correct: true,
      advance: true,
    );
    return true;
  }

  bool _isAnswerCorrect(Exercise exercise, String input) {
    if (exercise.type == ExerciseType.typeArrangeSentence) {
      final userAnswer = (exercise.userAnswer as List<String>).join('');
      final correctAnswer =
          exercise.correctAnswer.replaceAll(RegExp(r'\s+'), '');
      return userAnswer == correctAnswer;
    }
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
      case ExerciseType.typeArrangeSentence:
        normalized = normalized.replaceAll(RegExp(r'\s+'), '');
        break;
      default:
        final punctuation =
            RegExp(r'[，,。.?!？！；;："""()（）·…—《》〈〉、:_【】\[\]\-' + r"''" + r']');
        normalized = normalized
            .replaceAll(punctuation, '')
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
      // ⭐ Hoàn thành bài - cập nhật EXP và Streak
      _autoCloseAfterFinish();
      return;
    }

    currentIndex.value = nextIndex;
    currentExercise.value = processModel.exercises[nextIndex];
  }

  void _autoCloseAfterFinish() {
    // Gọi hàm update (không cần await ở đây vì là void)
    _updateExperienceAndStreak();

    final navigator = Get.key.currentState;
    Future.delayed(const Duration(milliseconds: 400), () {
      if (navigator != null && navigator.canPop()) {
        // Refresh word list progress in UI (if controller is registered)
        try {
          if (Get.isRegistered<WordListController>()) {
            Get.find<WordListController>().loadWords();
          }
          if (Get.isRegistered<SectionListController>()) {
            Get.find<SectionListController>().loadSections();
          }
        } catch (_) {
          // ignore if not present
        }
        navigator.pop({
          'results': results.toList(),
          'score': score.value,
          'total': totalExercises,
        });
      }
    });
  }

  // ⭐ CẬP NHẬT STREAK KHI HOÀN THÀNH BÀI
  void _updateExperienceAndStreak() {
    try {
      final correctCount = score.value;
      final totalCount = totalExercises;

      print('\n═══════════════════════════════════════��═══════════════════');
      print('🎉 HOÀN THÀNH BÀI LUYỆN TẬP');
      print('═══════════════════════���═══════════════════════════════════');
      print('📊 Kết quả: $correctCount/$totalCount câu trả lời đúng');
      print('⭐ EXP kiếm được: ${expEarned.value} EXP');

      // ⚠️ QUAN TRỌNG: Chỉ cần cập nhật STREAK khi hoàn thành bài
      // EXP đã được cập nhật từng câu trong _finalizeExercise()

      // 🔄 Gọi updateStreak() để cập nhật chuỗi ngày
      addExperienceUseCase(correctAnswers: 0, lessonCompleted: false).then((_) {
        print('✅ Streak đã cập nhật');
        print(
            '═══════════════════════════════���═══════���═══════════════════\n');
      }).catchError((e) {
        print('❌ Lỗi cập nhật Streak: $e');
        print(
            '════════════��═══════════════════════���══════════���═══════════\n');
      });
    } catch (e) {
      print('❌ Lỗi: $e');
    }
  }

  int _calculateNextLevel({
    required int previousLevel,
    required bool correct,
    required int totalCorrect,
  }) {
    if (!correct) {
      return max(0, previousLevel - 1);
    }
    // ⭐ Sửa: 7 câu đúng → level 5 (mastered)
    if (totalCorrect >= 7) {
      return 5;
    }
    if (totalCorrect >= 5) {
      return max(previousLevel, 4);
    }
    if (totalCorrect >= 3) {
      return max(previousLevel, 3);
    }
    if (totalCorrect >= 2) {
      return max(previousLevel, 2);
    }
    return max(previousLevel, 1);
  }

  /// ⭐ Cập nhật streak khi người dùng hoàn thành 1 từ vựng (mastered)
  Future<void> _updateStreakOnWordMastered() async {
    try {
      await userStatsRepository.updateStreak();
      print('🔥 [PRACTICE] Từ vựng được mastered! Streak được cập nhật');
    } catch (e) {
      print('❌ [PRACTICE] Lỗi cập nhật streak: $e');
    }
  }
}
