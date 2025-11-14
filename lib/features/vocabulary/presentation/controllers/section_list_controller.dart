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
    required this.groupSubtitle,
    required this.totalWords,
    required this.masteredWords,
  });

  final int sectionId;
  final int hskLevel;
  final String sectionTitle;
  final String groupSubtitle;
  final int totalWords;
  final int masteredWords;

  String get displayName =>
      groupSubtitle.isNotEmpty ? groupSubtitle : sectionTitle;

  double get progress => totalWords == 0 ? 0 : masteredWords / totalWords;
}

class SectionListController extends GetxController {
  SectionListController({
    required this.getSections,
    required this.getWordsBySection,
    required this.hskLevel,
  });

  final GetSections getSections;
  final GetWordsBySection getWordsBySection;
  final int hskLevel;

  final sections = <SectionProgress>[].obs;
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
      final filtered = items
          .where((item) => item.hskLevel == hskLevel)
          .toList()
        ..sort((a, b) => a.sectionId.compareTo(b.sectionId));
      sections.assignAll(filtered);
    } finally {
      isLoading.value = false;
    }
  }

  SectionProgress _buildProgress(int sectionId, List<Word> words) {
    final mastered = words.where((w) => w.mastered).length;
    final rawTitle = words.isNotEmpty ? words.first.sectionTitle : 'Section $sectionId';
    final subtitle =
        words.isNotEmpty && words.first.groupSubtitle.isNotEmpty ? words.first.groupSubtitle : rawTitle;
    final level = parseHskLevel(sectionId: sectionId, sectionTitle: rawTitle);
    return SectionProgress(
      sectionId: sectionId,
      hskLevel: level,
      sectionTitle: rawTitle,
      groupSubtitle: subtitle,
      totalWords: words.length,
      masteredWords: mastered,
    );
  }
}
