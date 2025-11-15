import 'package:get/get.dart';

import '../../domain/entities/word.dart';
import '../../domain/usecases/get_examples_by_word.dart';
import '../../domain/usecases/get_words_by_section.dart';
import '../utils/word_filters.dart';

class WordListController extends GetxController {
  WordListController({
    required this.sectionId,
    required this.sectionTitle,
    required this.getWordsBySection,
    required this.getExamplesByWord,
  });

  final int sectionId;
  final String sectionTitle;
  final GetWordsBySection getWordsBySection;
  final GetExamplesByWord getExamplesByWord;

  final words = <Word>[].obs;
  final isLoading = false.obs;

  int get totalWords => words.length;
  int get masteredCount => words.where((word) => word.mastered).length;

  @override
  void onInit() {
    super.onInit();
    loadWords();
  }

  Future<void> loadWords() async {
    isLoading.value = true;
    try {
      final result = await getWordsBySection(sectionId);
      final filtered = await dedupeWordsByExample(
        words: result,
        loadExamples: getExamplesByWord,
      );
      words.assignAll(filtered);
    } finally {
      isLoading.value = false;
    }
  }
}
