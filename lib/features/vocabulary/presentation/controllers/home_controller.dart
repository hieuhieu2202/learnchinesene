import 'package:get/get.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/word.dart';
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
  });

  final GetWordsToReviewToday getWordsToReviewToday;
  final GetSections getSections;
  final GetWordsBySection getWordsBySection;

  final reviewCount = 0.obs;
  final currentSectionId = 1.obs;
  final sections = <int>[].obs;
  final isLoading = false.obs;
  final hskOverview = <HskLevelOverview>[].obs;

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
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _buildHskOverview(List<int> sectionIds) async {
    final aggregates = <int, _LevelAggregate>{};

    for (final sectionId in sectionIds) {
      final words = await getWordsBySection(sectionId);
      if (words.isEmpty) {
        final level = parseHskLevel(sectionId: sectionId, sectionTitle: 'Section $sectionId');
        aggregates.putIfAbsent(level, _LevelAggregate.new).register();
        continue;
      }

      final Word firstWord = words.first;
      final level = parseHskLevel(
        sectionId: sectionId,
        sectionTitle: firstWord.sectionTitle,
      );
      final aggregate = aggregates.putIfAbsent(level, _LevelAggregate.new);
      aggregate.register(
        totalWords: words.length,
        masteredWords: words.where((w) => w.mastered).length,
      );
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
}

class _LevelAggregate {
  int sectionCount = 0;
  int totalWords = 0;
  int masteredWords = 0;

  void register({
    int totalWords = 0,
    int masteredWords = 0,
  }) {
    sectionCount += 1;
    this.totalWords += totalWords;
    this.masteredWords += masteredWords;
  }
}
