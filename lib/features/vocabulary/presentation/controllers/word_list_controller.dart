import 'package:get/get.dart';

import '../../domain/entities/word.dart';
import '../../domain/usecases/get_words_by_section.dart';

class WordListController extends GetxController {
  WordListController({
    required this.sectionId,
    required this.sectionTitle,
    required this.getWordsBySection,
  });

  final int sectionId;
  final String sectionTitle;
  final GetWordsBySection getWordsBySection;

  final words = <Word>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadWords();
  }

  Future<void> loadWords() async {
    isLoading.value = true;
    try {
      final result = await getWordsBySection(sectionId);
      words.assignAll(result);
    } finally {
      isLoading.value = false;
    }
  }
}
