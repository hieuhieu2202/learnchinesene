import 'package:get/get.dart' hide Progress;

import '../../domain/entities/example_sentence.dart';
import '../../domain/entities/progress_entity.dart';
import '../../domain/entities/word.dart';
import '../../domain/usecases/get_examples_by_word.dart';
import '../../domain/usecases/get_progress_for_word.dart';
import '../../domain/usecases/update_progress_after_quiz.dart';

enum PracticeMode {
  journey,
  typingMeaning,
  typingPinyin,
  typingHanzi,
  typingFillBlank,
  typingSentence,
  typingSentenceTransform,
  typingSecondExample,
  typingAiExplanation,
  typingRecap,
  typingConversation,
}

class PracticeQuestion {
  PracticeQuestion({
    required this.word,
    required this.stage,
    required this.title,
    required this.prompt,
    required this.inputLabel,
    required this.answer,
    required this.targetLevel,
    this.example,
    this.hint,
    this.extraHints = const <String>[],
    this.acceptableAnswers = const <String>[],
  });

  final Word word;
  final PracticeMode stage;
  final String title;
  final String prompt;
  final String inputLabel;
  final String answer;
  final int targetLevel;
  final ExampleSentence? example;
  final String? hint;
  final List<String> extraHints;
  final List<String> acceptableAnswers;
}

class GeneratedSentence {
  const GeneratedSentence({
    required this.chinese,
    required this.pinyin,
    required this.translation,
  });

  final String chinese;
  final String pinyin;
  final String translation;
}

class ConversationPrompt {
  const ConversationPrompt({
    required this.speakerAChinese,
    required this.speakerAPinyin,
    required this.speakerAMeaning,
    required this.speakerBChinese,
    required this.speakerBPinyin,
    required this.speakerBMeaning,
  });

  final String speakerAChinese;
  final String speakerAPinyin;
  final String speakerAMeaning;
  final String speakerBChinese;
  final String speakerBPinyin;
  final String speakerBMeaning;
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
  final Map<int, List<ExampleSentence>> _examplesCache = {};

  late final Worker _finishWorker;
  bool _hasAutoClosed = false;

  static const _orderedStages = <PracticeMode>[
    PracticeMode.typingMeaning,
    PracticeMode.typingPinyin,
    PracticeMode.typingHanzi,
    PracticeMode.typingFillBlank,
    PracticeMode.typingSentence,
    PracticeMode.typingSentenceTransform,
    PracticeMode.typingSecondExample,
    PracticeMode.typingAiExplanation,
    PracticeMode.typingRecap,
    PracticeMode.typingConversation,
  ];

  PracticeQuestion? get currentQuestion =>
      currentIndex.value < questions.length ? questions[currentIndex.value] : null;

  Future<void> restart() => _prepareQuestions();

  @override
  void onInit() {
    super.onInit();
    _finishWorker = ever<bool>(isFinished, _handleFinishedState);
    _prepareQuestions();
  }

  @override
  void onClose() {
    _finishWorker.dispose();
    super.onClose();
  }

  Future<void> markCorrect() async {
    final question = currentQuestion;
    if (question == null) return;
    await _handleResult(question: question, correct: true);
  }

  Future<void> markWrong({bool advance = true, bool requeue = false}) async {
    final question = currentQuestion;
    if (question == null) return;
    await _handleResult(
      question: question,
      correct: false,
      advanceOnWrong: advance,
      requeueOnWrong: requeue,
    );
  }

  Future<void> skipCurrent() async {
    await markWrong(advance: true);
  }

  Future<void> _prepareQuestions() async {
    isLoading.value = true;
    questions.clear();
    currentIndex.value = 0;
    score.value = 0;
    isFinished.value = false;
    _progressCache.clear();

    if (mode == PracticeMode.journey) {
      await _buildJourneyQuestions();
    } else {
      await _buildStageQuestions(mode);
    }

    isLoading.value = false;
    if (questions.isEmpty) {
      isFinished.value = true;
    }
  }

  void _handleFinishedState(bool finished) {
    if (!finished || _hasAutoClosed) {
      return;
    }
    _hasAutoClosed = true;

    final completedWords = <String>{};
    for (final question in questions) {
      completedWords.add(question.word.word);
    }

    final summaryLabel = completedWords.isEmpty
        ? 'từ vựng'
        : completedWords.length == 1
            ? completedWords.first
            : '${completedWords.length} từ';

    Get.snackbar(
      'Hoàn thành',
      'Bạn đã luyện xong $summaryLabel trong 10 bước!',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );

    final completedWordIds = <int>{};
    for (final question in questions) {
      completedWordIds.add(question.word.id);
    }

    Future.delayed(const Duration(milliseconds: 400), () {
      final navigator = Get.key.currentState;
      if (navigator != null && navigator.canPop()) {
        navigator.pop({
          'completedWordIds': completedWordIds.toList(),
          'score': score.value,
          'total': questions.length,
        });
      }
    });
  }

  Future<void> _buildJourneyQuestions() async {
    for (final word in words) {
      final progress = await _loadProgress(word.id);
      if (progress.mastered ||
          progress.level >= _stageToLevel(PracticeMode.typingConversation)) {
        continue;
      }

      final highestCompleted = progress.level
          .clamp(0, _stageToLevel(PracticeMode.typingConversation))
          .toInt();
      for (final stage in _orderedStages) {
        final stageLevel = _stageToLevel(stage);
        if (stageLevel <= highestCompleted) {
          continue;
        }
        final question = await _createQuestion(word, stage);
        if (question != null) {
          questions.add(question);
        }
      }
    }
  }

  Future<void> _buildStageQuestions(PracticeMode stage) async {
    for (final word in words) {
      await _loadProgress(word.id);
      final question = await _createQuestion(word, stage);
      if (question != null) {
        questions.add(question);
      }
    }
  }

  Future<PracticeQuestion?> _createQuestion(Word word, PracticeMode stage) async {
    switch (stage) {
      case PracticeMode.typingMeaning:
        return PracticeQuestion(
          word: word,
          stage: stage,
          title: 'Bước 1 · Gõ nghĩa',
          prompt: '${word.word}\n(${word.transliteration})',
          inputLabel: 'Nhập nghĩa tiếng Việt / Anh',
          answer: word.translation,
          acceptableAnswers: _splitAlternatives(word.translation),
          targetLevel: 1,
        );
      case PracticeMode.typingPinyin:
        return PracticeQuestion(
          word: word,
          stage: stage,
          title: 'Bước 2 · Gõ pinyin',
          prompt: word.word,
          inputLabel: 'Nhập pinyin có dấu hoặc không dấu',
          answer: word.transliteration,
          acceptableAnswers: _splitAlternatives(word.transliteration),
          hint: 'Nghĩa: ${word.translation}',
          targetLevel: 2,
        );
      case PracticeMode.typingHanzi:
        return PracticeQuestion(
          word: word,
          stage: stage,
          title: 'Bước 3 · Gõ chữ Hán',
          prompt: 'Nghĩa: ${word.translation}\nPinyin: ${word.transliteration}',
          inputLabel: 'Nhập chữ Hán tương ứng',
          answer: word.word,
          targetLevel: 3,
        );
      case PracticeMode.typingFillBlank:
        final example = await _pickExample(word);
        if (example == null) {
          return null;
        }
        final masked = _maskWord(example.sentenceCn, word.word);
        if (masked == null) {
          return null;
        }
        return PracticeQuestion(
          word: word,
          stage: stage,
          title: 'Bước 4 · Điền từ vào câu',
          prompt: masked,
          inputLabel: 'Nhập từ còn thiếu',
          answer: word.word,
          example: example,
          extraHints: [
            'Pinyin câu: ${example.sentencePinyin}',
            'Nghĩa: ${example.sentenceVi}',
          ],
          targetLevel: 4,
        );
      case PracticeMode.typingSentence:
        final example = await _pickExample(word);
        if (example == null) {
          return null;
        }
        return PracticeQuestion(
          word: word,
          stage: stage,
          title: 'Bước 5 · Gõ lại câu ví dụ',
          prompt: example.sentenceVi,
          inputLabel: 'Gõ lại câu tiếng Trung',
          answer: example.sentenceCn,
          example: example,
          extraHints: [
            'Pinyin tham khảo: ${example.sentencePinyin}',
          ],
          targetLevel: 5,
        );
      case PracticeMode.typingSentenceTransform:
        final baseExample = await _pickExample(word);
        final transformed = _generateTransformedSentence(word);
        return PracticeQuestion(
          word: word,
          stage: stage,
          title: 'Bước 6 · Biến đổi câu',
          prompt:
              'Hãy gõ lại câu tiếng Trung mới dựa trên ý nghĩa sau:\n${transformed.translation}',
          inputLabel: 'Nhập câu biến đổi',
          answer: transformed.chinese,
          example: baseExample,
          extraHints: [
            'Gợi ý pinyin: ${transformed.pinyin}',
          ],
          targetLevel: 6,
        );
      case PracticeMode.typingSecondExample:
        var example = await _pickExample(word, index: 1);
        example ??= await _pickExample(word);
        if (example == null) {
          return null;
        }
        return PracticeQuestion(
          word: word,
          stage: stage,
          title: 'Bước 7 · Ví dụ thứ hai',
          prompt: example.sentenceVi,
          inputLabel: 'Gõ lại câu ví dụ thứ hai',
          answer: example.sentenceCn,
          example: example,
          extraHints: [
            'Pinyin tham khảo: ${example.sentencePinyin}',
          ],
          targetLevel: 7,
        );
      case PracticeMode.typingAiExplanation:
        final explanation = _generateExplanationSentence(word);
        return PracticeQuestion(
          word: word,
          stage: stage,
          title: 'Bước 8 · Câu giải thích',
          prompt:
              'Gõ lại câu giải thích giúp bạn hiểu từ sâu hơn:\n${explanation.translation}',
          inputLabel: 'Nhập câu giải thích',
          answer: explanation.chinese,
          extraHints: [
            'Pinyin câu: ${explanation.pinyin}',
          ],
          targetLevel: 8,
        );
      case PracticeMode.typingRecap:
        final recapAnswer = _buildRecapAnswer(word);
        return PracticeQuestion(
          word: word,
          stage: stage,
          title: 'Bước 9 · Ôn tổng hợp',
          prompt:
              'Gõ lại đầy đủ chữ Hán + pinyin + nghĩa của từ này theo thứ tự.',
          inputLabel: 'Ví dụ: 水 shui water',
          answer: recapAnswer,
          extraHints: [
            'Gợi ý: ${word.word} ${_normalizePinyinSpacing(word.transliteration)} ${word.translation}',
          ],
          targetLevel: 9,
        );
      case PracticeMode.typingConversation:
        final conversation = _generateConversation(word);
        return PracticeQuestion(
          word: word,
          stage: stage,
          title: 'Bước 10 · Hội thoại ngắn',
          prompt:
              'A: ${conversation.speakerAChinese}\n(${conversation.speakerAMeaning})\nB: ______\n\nGõ lại câu trả lời của B.',
          inputLabel: 'Nhập câu trả lời của B',
          answer: conversation.speakerBChinese,
          extraHints: [
            'Pinyin đáp án: ${conversation.speakerBPinyin}',
            'Nghĩa: ${conversation.speakerBMeaning}',
          ],
          targetLevel: 10,
        );
      case PracticeMode.journey:
        return null;
    }
  }

  Future<bool> submitTypedAnswer(String input) async {
    final question = currentQuestion;
    if (question == null) {
      return false;
    }

    final isCorrect = _isAnswerCorrect(question, input);
    await _handleResult(
      question: question,
      correct: isCorrect,
      advanceOnWrong: false,
    );
    return isCorrect;
  }

  Future<void> _handleResult({
    required PracticeQuestion question,
    required bool correct,
    bool advanceOnWrong = false,
    bool requeueOnWrong = false,
  }) async {
    if (correct) {
      score.value++;
    }
    await _updateProgress(question: question, correct: correct);
    _moveNext(
      question: question,
      correct: correct,
      advanceOnWrong: advanceOnWrong,
      requeueOnWrong: requeueOnWrong,
    );
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

  Future<List<ExampleSentence>> _loadExamples(int wordId) async {
    final cached = _examplesCache[wordId];
    if (cached != null) {
      return cached;
    }
    final examples = await getExamplesByWord(wordId);
    _examplesCache[wordId] = examples;
    return examples;
  }

  Future<ExampleSentence?> _pickExample(Word word, {int index = 0}) async {
    final examples = await _loadExamples(word.id);
    if (examples.isEmpty) {
      return null;
    }

    final matching = examples
        .where((example) => example.sentenceCn.contains(word.word))
        .toList();
    final source = matching.isEmpty ? examples : matching;

    if (index >= 0 && index < source.length) {
      return source[index];
    }

    return source.isNotEmpty ? source.last : null;
  }

  GeneratedSentence _generateTransformedSentence(Word word) {
    final pinyinWord = _normalizePinyinSpacing(word.transliteration);
    final chinese = '他很喜欢${word.word}。';
    final pinyin = 'tā hěn xǐhuan $pinyinWord.';
    return GeneratedSentence(
      chinese: chinese,
      pinyin: pinyin,
      translation: 'Anh ấy rất thích ${word.translation}.',
    );
  }

  GeneratedSentence _generateExplanationSentence(Word word) {
    final pinyinWord = _normalizePinyinSpacing(word.transliteration);
    final sanitizedMeaning = _sanitizeForPinyin(word.translation);
    return GeneratedSentence(
      chinese: '${word.word} 表示${word.translation}。',
      pinyin: '$pinyinWord biǎoshì $sanitizedMeaning.',
      translation: '${word.word} là từ dùng để diễn tả "${word.translation}".',
    );
  }

  ConversationPrompt _generateConversation(Word word) {
    final pinyinWord = _normalizePinyinSpacing(word.transliteration);
    return ConversationPrompt(
      speakerAChinese: '你想要什么？',
      speakerAPinyin: 'nǐ xiǎng yào shénme?',
      speakerAMeaning: 'Bạn muốn gì?',
      speakerBChinese: '我想要${word.word}。',
      speakerBPinyin: 'wǒ xiǎng yào $pinyinWord.',
      speakerBMeaning: 'Tôi muốn ${word.translation}.',
    );
  }

  String _buildRecapAnswer(Word word) {
    final pinyinWord = _normalizePinyinSpacing(word.transliteration);
    final meaning = word.translation.trim();
    return '${word.word} $pinyinWord $meaning';
  }

  String? _maskWord(String sentence, String word) {
    if (word.isEmpty) return null;
    final pattern = RegExp(RegExp.escape(word));
    if (!pattern.hasMatch(sentence)) {
      return null;
    }
    return sentence.replaceAll(pattern, '____');
  }

  bool _isAnswerCorrect(PracticeQuestion question, String input) {
    final normalizedInput = _normalizeByStage(question.stage, input);
    if (normalizedInput.isEmpty) {
      return false;
    }
    final normalizedAnswer = _normalizeByStage(question.stage, question.answer);
    if (normalizedInput == normalizedAnswer) {
      return true;
    }
    for (final alternative in question.acceptableAnswers) {
      if (normalizedInput == _normalizeByStage(question.stage, alternative)) {
        return true;
      }
    }
    return false;
  }

  String _normalizeByStage(PracticeMode stage, String value) {
    switch (stage) {
      case PracticeMode.typingMeaning:
        return _normalizeMeaning(value);
      case PracticeMode.typingPinyin:
        return _normalizePinyin(value);
      case PracticeMode.typingHanzi:
      case PracticeMode.typingFillBlank:
        return _normalizeHanzi(value);
      case PracticeMode.typingSentence:
      case PracticeMode.typingSentenceTransform:
      case PracticeMode.typingSecondExample:
      case PracticeMode.typingAiExplanation:
      case PracticeMode.typingConversation:
        return _normalizeSentence(value);
      case PracticeMode.typingRecap:
        return _normalizeRecap(value);
      case PracticeMode.journey:
        return value.trim();
    }
  }

  String _normalizeMeaning(String value) {
    final base = _removeDiacritics(value).toLowerCase();
    final cleaned = base.replaceAll(_punctuationRegex, ' ');
    return cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _normalizePinyin(String value) {
    final base = _removeDiacritics(value).toLowerCase();
    return base.replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  String _normalizeHanzi(String value) {
    final cleaned = value.replaceAll(_punctuationRegex, '');
    return cleaned.replaceAll(RegExp(r'\s+'), '').trim();
  }

  String _normalizeSentence(String value) => _normalizeHanzi(value);

  String _normalizeRecap(String value) {
    final cleaned = _removeDiacritics(value).toLowerCase();
    final withoutPunctuation = cleaned.replaceAll(_punctuationRegex, ' ');
    return withoutPunctuation.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _normalizePinyinSpacing(String value) => value.replaceAll(RegExp(r'\s+'), ' ').trim();

  String _sanitizeForPinyin(String value) {
    final cleaned = _removeDiacritics(value);
    final ascii = cleaned.replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), ' ');
    return ascii.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  Future<void> _updateProgress({
    required PracticeQuestion question,
    required bool correct,
  }) async {
    final wordId = question.word.id;
    final progress = await _loadProgress(wordId);

    final nextCorrect = correct ? progress.correctCount + 1 : progress.correctCount;
    final nextWrong = correct ? progress.wrongCount : progress.wrongCount + 1;
    final stageLevel = question.targetLevel;
    final nextLevel =
        correct ? (progress.level >= stageLevel ? progress.level : stageLevel) : progress.level;
    final mastered = correct && question.targetLevel >= 10
        ? true
        : progress.mastered;

    await updateProgressAfterQuiz(
      UpdateProgressParams(
        progress: progress,
        correctCount: nextCorrect,
        wrongCount: nextWrong,
        level: nextLevel,
        mastered: mastered,
      ),
    );

    _progressCache[wordId] = progress.copyWith(
      correctCount: nextCorrect,
      wrongCount: nextWrong,
      level: nextLevel,
      mastered: mastered,
      lastPractice: DateTime.now(),
    );
  }

  void _moveNext({
    required PracticeQuestion question,
    required bool correct,
    required bool advanceOnWrong,
    required bool requeueOnWrong,
  }) {
    if (!correct && !advanceOnWrong) {
      return;
    }

    if (!correct && advanceOnWrong && requeueOnWrong) {
      questions.add(question);
    }

    if (currentIndex.value + 1 >= questions.length) {
      isFinished.value = true;
    } else {
      currentIndex.value++;
    }
  }

  int _stageToLevel(PracticeMode stage) {
    switch (stage) {
      case PracticeMode.typingMeaning:
        return 1;
      case PracticeMode.typingPinyin:
        return 2;
      case PracticeMode.typingHanzi:
        return 3;
      case PracticeMode.typingFillBlank:
        return 4;
      case PracticeMode.typingSentence:
        return 5;
      case PracticeMode.typingSentenceTransform:
        return 6;
      case PracticeMode.typingSecondExample:
        return 7;
      case PracticeMode.typingAiExplanation:
        return 8;
      case PracticeMode.typingRecap:
        return 9;
      case PracticeMode.typingConversation:
        return 10;
      case PracticeMode.journey:
        return 0;
    }
  }

  List<String> _splitAlternatives(String raw) {
    final cleaned = raw.trim();
    if (cleaned.isEmpty) {
      return const [];
    }

    final candidates = cleaned
        .split(RegExp(r'[;,/]|\bor\b|\band\b', caseSensitive: false))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();

    final seen = <String>{};
    final results = <String>[];

    for (final candidate in candidates) {
      final key = candidate.toLowerCase();
      if (seen.add(key)) {
        results.add(candidate);
      }
    }

    if (seen.add(cleaned.toLowerCase())) {
      results.add(cleaned);
    }

    return results;
  }

  String _removeDiacritics(String input) {
    final buffer = StringBuffer();
    for (final codePoint in input.runes) {
      final char = String.fromCharCode(codePoint);
      buffer.write(_diacriticMap[char] ?? char);
    }
    return buffer.toString();
  }

  static final _punctuationRegex = RegExp(
    r'''[，,。.?!？！；;：“”"'()（）·…—《》〈〉、:_【】\[\]-]''',
  );

  static final Map<String, String> _diacriticMap = {
    ..._vietnameseDiacritics,
    ..._pinyinDiacritics,
  };

  static const Map<String, String> _vietnameseDiacritics = {
    'à': 'a',
    'á': 'a',
    'ả': 'a',
    'ã': 'a',
    'ạ': 'a',
    'â': 'a',
    'ầ': 'a',
    'ấ': 'a',
    'ẩ': 'a',
    'ẫ': 'a',
    'ậ': 'a',
    'ă': 'a',
    'ằ': 'a',
    'ắ': 'a',
    'ẳ': 'a',
    'ẵ': 'a',
    'ặ': 'a',
    'À': 'A',
    'Á': 'A',
    'Ả': 'A',
    'Ã': 'A',
    'Ạ': 'A',
    'Â': 'A',
    'Ầ': 'A',
    'Ấ': 'A',
    'Ẩ': 'A',
    'Ẫ': 'A',
    'Ậ': 'A',
    'Ă': 'A',
    'Ằ': 'A',
    'Ắ': 'A',
    'Ẳ': 'A',
    'Ẵ': 'A',
    'Ặ': 'A',
    'è': 'e',
    'é': 'e',
    'ẻ': 'e',
    'ẽ': 'e',
    'ẹ': 'e',
    'ê': 'e',
    'ề': 'e',
    'ế': 'e',
    'ể': 'e',
    'ễ': 'e',
    'ệ': 'e',
    'È': 'E',
    'É': 'E',
    'Ẻ': 'E',
    'Ẽ': 'E',
    'Ẹ': 'E',
    'Ê': 'E',
    'Ề': 'E',
    'Ế': 'E',
    'Ể': 'E',
    'Ễ': 'E',
    'Ệ': 'E',
    'ì': 'i',
    'í': 'i',
    'ỉ': 'i',
    'ĩ': 'i',
    'ị': 'i',
    'Ì': 'I',
    'Í': 'I',
    'Ỉ': 'I',
    'Ĩ': 'I',
    'Ị': 'I',
    'ò': 'o',
    'ó': 'o',
    'ỏ': 'o',
    'õ': 'o',
    'ọ': 'o',
    'ô': 'o',
    'ồ': 'o',
    'ố': 'o',
    'ổ': 'o',
    'ỗ': 'o',
    'ộ': 'o',
    'ơ': 'o',
    'ờ': 'o',
    'ớ': 'o',
    'ở': 'o',
    'ỡ': 'o',
    'ợ': 'o',
    'Ò': 'O',
    'Ó': 'O',
    'Ỏ': 'O',
    'Õ': 'O',
    'Ọ': 'O',
    'Ô': 'O',
    'Ồ': 'O',
    'Ố': 'O',
    'Ổ': 'O',
    'Ỗ': 'O',
    'Ộ': 'O',
    'Ơ': 'O',
    'Ờ': 'O',
    'Ớ': 'O',
    'Ở': 'O',
    'Ỡ': 'O',
    'Ợ': 'O',
    'ù': 'u',
    'ú': 'u',
    'ủ': 'u',
    'ũ': 'u',
    'ụ': 'u',
    'ư': 'u',
    'ừ': 'u',
    'ứ': 'u',
    'ử': 'u',
    'ữ': 'u',
    'ự': 'u',
    'Ù': 'U',
    'Ú': 'U',
    'Ủ': 'U',
    'Ũ': 'U',
    'Ụ': 'U',
    'Ư': 'U',
    'Ừ': 'U',
    'Ứ': 'U',
    'Ử': 'U',
    'Ữ': 'U',
    'Ự': 'U',
    'ỳ': 'y',
    'ý': 'y',
    'ỷ': 'y',
    'ỹ': 'y',
    'ỵ': 'y',
    'Ỳ': 'Y',
    'Ý': 'Y',
    'Ỷ': 'Y',
    'Ỹ': 'Y',
    'Ỵ': 'Y',
    'đ': 'd',
    'Đ': 'D',
  };

  static const Map<String, String> _pinyinDiacritics = {
    'ā': 'a',
    'ǎ': 'a',
    'ē': 'e',
    'ě': 'e',
    'ī': 'i',
    'ǐ': 'i',
    'ō': 'o',
    'ǒ': 'o',
    'ū': 'u',
    'ǔ': 'u',
    'ǖ': 'v',
    'ǘ': 'v',
    'ǚ': 'v',
    'ǜ': 'v',
    'ü': 'v',
    'Ā': 'A',
    'Ǎ': 'A',
    'Ē': 'E',
    'Ě': 'E',
    'Ī': 'I',
    'Ǐ': 'I',
    'Ō': 'O',
    'Ǒ': 'O',
    'Ū': 'U',
    'Ǔ': 'U',
    'Ǖ': 'V',
    'Ǘ': 'V',
    'Ǚ': 'V',
    'Ǜ': 'V',
    'Ü': 'V',
    'ń': 'n',
    'ň': 'n',
    'ǹ': 'n',
    'Ń': 'N',
    'Ň': 'N',
    'Ǹ': 'N',
    'ḿ': 'm',
    'Ḿ': 'M',
  };
}
