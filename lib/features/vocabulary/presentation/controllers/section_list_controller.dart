import 'package:get/get.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/word.dart';
import '../../domain/usecases/get_sections.dart';
import '../../domain/usecases/get_words_by_section.dart';
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
  });

  final int sectionId;
  final int hskLevel;
  final String sectionTitle;
  final String topicTitle;
  final int sectionNumber;
  final int unitNumber;
  final int totalWords;
  final int masteredWords;

  String get displayName => topicTitle.isNotEmpty ? topicTitle : sectionTitle;
  String get unitLabel => 'Unit $unitNumber';
  double get progress => totalWords == 0 ? 0 : masteredWords / totalWords;
}

class SectionListController extends GetxController {
  SectionListController({
    required this.getSections,
    required this.getWordsBySection,
    required int initialLevel,
  }) {
    selectedLevel.value = initialLevel;
  }

  final GetSections getSections;
  final GetWordsBySection getWordsBySection;

  final sections = <SectionProgress>[].obs;
  final _allSections = <SectionProgress>[];
  final selectedLevel = 1.obs;
  final isLoading = false.obs;

  int get totalWords => sections.fold<int>(0, (sum, item) => sum + item.totalWords);
  int get masteredWords => sections.fold<int>(0, (sum, item) => sum + item.masteredWords);
  double get progress => totalWords == 0 ? 0 : masteredWords / totalWords;

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
        items.add(_buildProgress(id, words));
      }
      _allSections
        ..clear()
        ..addAll(items);
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

  SectionProgress _buildProgress(int sectionId, List<Word> words) {
    final mastered = words.where((w) => w.mastered).length;
    final rawTitle = words.isNotEmpty ? words.first.sectionTitle : 'Section $sectionId';
    final topicTitle = words.isNotEmpty && words.first.groupSubtitle.isNotEmpty
        ? words.first.groupSubtitle
        : rawTitle;
    final level = parseHskLevel(sectionId: sectionId, sectionTitle: rawTitle);
    final sectionNumber = _extractNumber(rawTitle, 'Section') ?? level;
    final unitNumber = _extractNumber(rawTitle, 'Unit') ?? sectionId + 1;
    return SectionProgress(
      sectionId: sectionId,
      hskLevel: level,
      sectionTitle: rawTitle,
      topicTitle: topicTitle,
      sectionNumber: sectionNumber,
      unitNumber: unitNumber,
      totalWords: words.length,
      masteredWords: mastered,
    );
  }
}

int? _extractNumber(String source, String label) {
  final match = RegExp('$label\\s*(\\d+)', caseSensitive: false).firstMatch(source);
  if (match == null) {
    return null;
  }
  return int.tryParse(match.group(1)!);
}
