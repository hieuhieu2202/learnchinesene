import 'package:get/get.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/word.dart';
import '../../domain/usecases/get_sections.dart';
import '../../domain/usecases/get_words_by_section.dart';
import '../../domain/usecases/get_progress_for_word.dart';
import '../utils/hsk_utils.dart';

class SectionProgress {
  SectionProgress({
    required this.sectionId,
    required this.hskLevel,
    required this.sectionTitle,
    required this.topicTitle,
    required this.sectionNumber,
    required this.unitNumber,
    required this.totalWords,
    required this.masteredWords,
    required this.progress,
    required this.unlocked,
  });

  final int sectionId;
  final int hskLevel;
  final String sectionTitle;
  final String topicTitle;
  final int sectionNumber;
  final int unitNumber;
  final int totalWords;
  final int masteredWords;
  // progress: average per-word progress in this section (0.0 - 1.0)
  final double progress;
  final bool unlocked;

  String get displayName => topicTitle.isNotEmpty ? topicTitle : sectionTitle;
  String get unitLabel => 'Unit $unitNumber';
  bool get isLocked => !unlocked;

  SectionProgress copyWith({
    int? masteredWords,
    double? progress,
    bool? unlocked,
  }) {
    return SectionProgress(
      sectionId: sectionId,
      hskLevel: hskLevel,
      sectionTitle: sectionTitle,
      topicTitle: topicTitle,
      sectionNumber: sectionNumber,
      unitNumber: unitNumber,
      totalWords: totalWords,
      masteredWords: masteredWords ?? this.masteredWords,
      progress: progress ?? this.progress,
      unlocked: unlocked ?? this.unlocked,
    );
  }
}

class SectionListController extends GetxController {
  SectionListController({
    required this.getSections,
    required this.getWordsBySection,
    required this.getProgressForWord,
    required int initialLevel,
  }) {
    selectedLevel.value = initialLevel;
  }

  final GetSections getSections;
  final GetWordsBySection getWordsBySection;
  final GetProgressForWord getProgressForWord;
  static const double _unlockThreshold = 1.0;

  final sections = <SectionProgress>[].obs;
  final _allSections = <SectionProgress>[];
  final selectedLevel = 1.obs;
  final isLoading = false.obs;

  int get totalWords => sections.fold<int>(0, (sum, item) => sum + item.totalWords);
  int get masteredWords => sections.fold<int>(0, (sum, item) => sum + item.masteredWords);

  // Progress for the selected HSK level is the weighted average of
  // each section's progress (weight = number of words in the section).
  double get progress {
    final secs = sections;
    if (secs.isEmpty) return 0.0;
    final total = secs.fold<int>(0, (s, item) => s + item.totalWords);
    if (total == 0) return 0.0;
    final weighted = secs.fold<double>(0.0, (s, item) => s + (item.progress * item.totalWords));
    return (weighted / total).clamp(0.0, 1.0);
  }

  @override
  void onInit() {
    super.onInit();
    loadSections();
  }

  Future<void> loadSections() async {
    isLoading.value = true;
    try {
      final sectionIds = await getSections(const NoParams());
      final items = <SectionProgress>[];
      for (final id in sectionIds) {
        final words = await getWordsBySection(id);
        final sectionProgress = await _buildProgress(id, words);
        items.add(sectionProgress);
      }
      final unlockedItems = _applyUnlockState(items);
      _allSections
        ..clear()
        ..addAll(unlockedItems);
      _applyFilter();
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilter() {
    final filtered = _allSections
        .where((item) => item.hskLevel == selectedLevel.value)
        .toList()
      ..sort((a, b) => a.unitNumber.compareTo(b.unitNumber));
    sections.assignAll(filtered);
  }

  // Build section progress by aggregating per-word progress values.
  // Per-word progress is computed as min(1.0, correctCount * 0.1).
  Future<SectionProgress> _buildProgress(int sectionId, List<Word> words) async {
    final rawTitle = words.isNotEmpty ? words.first.sectionTitle : 'Section $sectionId';
    final topicTitle = words.isNotEmpty && words.first.groupSubtitle.isNotEmpty
        ? words.first.groupSubtitle
        : rawTitle;
    final level = parseHskLevel(sectionId: sectionId, sectionTitle: rawTitle);
    final sectionNumber = _extractNumber(rawTitle, 'Section') ?? level;
    final unitNumber = _extractNumber(rawTitle, 'Unit') ?? sectionId + 1;

    if (words.isEmpty) {
      return SectionProgress(
        sectionId: sectionId,
        hskLevel: level,
        sectionTitle: rawTitle,
        topicTitle: topicTitle,
        sectionNumber: sectionNumber,
        unitNumber: unitNumber,
        totalWords: 0,
        masteredWords: 0,
        progress: 0.0,
        unlocked: true,
      );
    }

    double totalProgress = 0.0;
    int masteredCount = 0;

    // Fetch progress for all words in parallel
    final futures = words.map((w) async {
      final p = await getProgressForWord(w.id);
      final correct = p?.correctCount ?? 0;
      final frac = (correct * 0.1).clamp(0.0, 1.0);
      if (p?.mastered ?? false) masteredCount += 1;
      return frac;
    }).toList();

    final results = await Future.wait(futures);
    for (final frac in results) {
      totalProgress += frac;
    }

    final avgProgress = (totalProgress / words.length).clamp(0.0, 1.0);

    return SectionProgress(
      sectionId: sectionId,
      hskLevel: level,
      sectionTitle: rawTitle,
      topicTitle: topicTitle,
      sectionNumber: sectionNumber,
      unitNumber: unitNumber,
      totalWords: words.length,
      masteredWords: masteredCount,
      progress: avgProgress,
      unlocked: true,
    );
  }

  List<SectionProgress> _applyUnlockState(List<SectionProgress> items) {
    final grouped = <int, List<SectionProgress>>{};
    final unlockMap = <int, bool>{};
    for (final section in items) {
      grouped.putIfAbsent(section.hskLevel, () => []).add(section);
    }
    for (final group in grouped.values) {
      group.sort((a, b) => a.unitNumber.compareTo(b.unitNumber));
      for (var i = 0; i < group.length; i++) {
        final isUnlocked = i == 0 || group[i - 1].progress >= _unlockThreshold;
        unlockMap[group[i].sectionId] = isUnlocked;
      }
    }
    return [
      for (final section in items)
        section.copyWith(unlocked: unlockMap[section.sectionId] ?? true),
    ];
  }
}

int? _extractNumber(String source, String label) {
  final match = RegExp('$label\\s*(\\d+)', caseSensitive: false).firstMatch(source);
  if (match == null) {
    return null;
  }
  return int.tryParse(match.group(1)!);
}
