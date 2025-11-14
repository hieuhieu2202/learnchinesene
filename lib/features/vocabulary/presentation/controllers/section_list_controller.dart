import 'package:get/get.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../domain/entities/word.dart';
import '../../../domain/usecases/get_sections.dart';
import '../../../domain/usecases/get_words_by_section.dart';

class SectionProgress {
  SectionProgress({
    required this.sectionId,
    required this.title,
    required this.totalWords,
    required this.masteredWords,
  });

  final int sectionId;
  final String title;
  final int totalWords;
  final int masteredWords;

  double get progress => totalWords == 0 ? 0 : masteredWords / totalWords;
}

class SectionListController extends GetxController {
  SectionListController({
    required this.getSections,
    required this.getWordsBySection,
  });

  final GetSections getSections;
  final GetWordsBySection getWordsBySection;

  final sections = <SectionProgress>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSections();
  }

  Future<void> loadSections() async {
    isLoading.value = true;
    try {
      final sectionIds = await getSections(NoParams());
      final items = <SectionProgress>[];
      for (final id in sectionIds) {
        final words = await getWordsBySection(id);
        items.add(_buildProgress(id, words));
      }
      sections.assignAll(items);
    } finally {
      isLoading.value = false;
    }
  }

  SectionProgress _buildProgress(int sectionId, List<Word> words) {
    final mastered = words.where((w) => w.mastered).length;
    final title = words.isNotEmpty ? words.first.sectionTitle : 'Section $sectionId';
    return SectionProgress(
      sectionId: sectionId,
      title: title,
      totalWords: words.length,
      masteredWords: mastered,
    );
  }
}
