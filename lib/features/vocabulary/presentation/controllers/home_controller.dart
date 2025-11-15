import 'package:get/get.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/word.dart';
import '../../domain/entities/example_sentence.dart';
import '../../domain/usecases/get_examples_by_word.dart';
import '../../domain/usecases/get_sections.dart';
import '../../domain/usecases/get_words_by_section.dart';
import '../../domain/usecases/get_words_to_review_today.dart';
import '../utils/hsk_utils.dart';

class HskLevelOverview {
  HskLevelOverview({
    required this.level,
    required this.sectionCount,
    required this.totalWords,
    required this.masteredWords,
  });

  final int level;
  final int sectionCount;
  final int totalWords;
  final int masteredWords;

  double get progress => totalWords == 0 ? 0 : masteredWords / totalWords;
}

class HomeController extends GetxController {
  HomeController({
    required this.getWordsToReviewToday,
    required this.getSections,
    required this.getWordsBySection,
    required this.getExamplesByWord,
  });

  final GetWordsToReviewToday getWordsToReviewToday;
  final GetSections getSections;
  final GetWordsBySection getWordsBySection;
  final GetExamplesByWord getExamplesByWord;

  final reviewCount = 0.obs;
  final currentSectionId = 1.obs;
  final sections = <int>[].obs;
  final isLoading = false.obs;
  final hskOverview = <HskLevelOverview>[].obs;
  final selectedTab = 0.obs;
  final aiSentenceSamples = <AiSentenceSample>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    try {
      final today = DateTime.now();
      final wordsToReview = await getWordsToReviewToday(today);
      reviewCount.value = wordsToReview.length;
      sections.assignAll(await getSections(const NoParams()));
      if (sections.isNotEmpty) {
        currentSectionId.value = sections.first;
      }
      await _buildHskOverview(sections);
      await _loadAiSentenceSamples(sections);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _buildHskOverview(List<int> sectionIds) async {
    final aggregates = <int, _LevelAggregate>{};

    for (final sectionId in sectionIds) {
      final words = await getWordsBySection(sectionId);
      final referenceTitle =
          words.isNotEmpty ? words.first.sectionTitle : 'Section $sectionId';
      final level = parseHskLevel(
        sectionId: sectionId,
        sectionTitle: referenceTitle,
      );
      final aggregate = aggregates.putIfAbsent(level, _LevelAggregate.new);

      if (words.isEmpty) {
        aggregate.registerEmpty(sectionId);
        continue;
      }

      aggregate.registerSection(sectionId, words);
    }

    final overviewItems = <HskLevelOverview>[];
    for (var level = 1; level <= 4; level++) {
      final data = aggregates[level];
      overviewItems.add(
        HskLevelOverview(
          level: level,
          sectionCount: data?.sectionCount ?? 0,
          totalWords: data?.totalWords ?? 0,
          masteredWords: data?.masteredWords ?? 0,
        ),
      );
    }

    final additionalLevels = aggregates.keys
        .where((level) => level > 4)
        .toList()
      ..sort();
    for (final level in additionalLevels) {
      final data = aggregates[level]!;
      overviewItems.add(
        HskLevelOverview(
          level: level,
          sectionCount: data.sectionCount,
          totalWords: data.totalWords,
          masteredWords: data.masteredWords,
        ),
      );
    }

    hskOverview.assignAll(overviewItems);
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  Future<void> _loadAiSentenceSamples(List<int> sectionIds) async {
    final samples = <AiSentenceSample>[];
    for (final sectionId in sectionIds) {
      if (samples.length >= 6) break;
      final words = await getWordsBySection(sectionId);
      if (words.isEmpty) continue;

      for (final word in words) {
        final examples = await getExamplesByWord(word.id);
        if (examples.isEmpty) continue;

        samples.add(
          AiSentenceSample(
            wordId: word.id,
            word: word.word,
            sectionTitle: word.sectionTitle,
            groupSubtitle: word.groupSubtitle,
            example: examples.first,
          ),
        );

        if (samples.length >= 6) break;
      }
    }

    aiSentenceSamples.assignAll(samples);
  }
}

class AiSentenceSample {
  AiSentenceSample({
    required this.wordId,
    required this.word,
    required this.sectionTitle,
    required this.groupSubtitle,
    required this.example,
  });

  final int wordId;
  final String word;
  final String sectionTitle;
  final String groupSubtitle;
  final ExampleSentence example;

  String get contextLabel =>
      groupSubtitle.isEmpty ? sectionTitle : '$sectionTitle · $groupSubtitle';
}

class _LevelAggregate {
  final Set<int> _sectionIds = {};
  final Set<int> _wordIds = {};
  final Map<int, bool> _masteredState = {};

  void registerEmpty(int sectionId) {
    _sectionIds.add(sectionId);
  }

  void registerSection(int sectionId, Iterable<Word> words) {
    _sectionIds.add(sectionId);
    for (final word in words) {
      _wordIds.add(word.id);
      final previous = _masteredState[word.id] ?? false;
      _masteredState[word.id] = previous || word.mastered;
    }
  }

  int get sectionCount => _sectionIds.length;
  int get totalWords => _wordIds.length;
  int get masteredWords =>
      _masteredState.values.where((isMastered) => isMastered).length;
}
