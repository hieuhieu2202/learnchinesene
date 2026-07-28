import 'package:get/get.dart';

import '../../domain/entities/word.dart';
import '../../domain/usecases/get_words_by_section.dart';
import '../../domain/usecases/get_progress_for_word.dart';

class WordListController extends GetxController {
  WordListController({
    required this.sectionId,
    required this.sectionTitle,
    required this.getWordsBySection,
    required this.getProgressForWord,
  });

  final int sectionId;
  final String sectionTitle;
  final GetWordsBySection getWordsBySection;
  final GetProgressForWord getProgressForWord;
  bool isUnlocked = true;

  final words = <Word>[].obs;
  final isLoading = false.obs;

  // Cache per-word progress as fraction (0.0 - 1.0).
  // Progress is computed as correctCount * 0.1, capped at 1.0
  final Map<int, double> _progressMap = {};

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
      words.assignAll(result);
      if (result.isNotEmpty &&
          result.first.groupSubtitle.contains('[LOCKED]')) {
        isUnlocked = false;
      }
      // Load progress for all words and cache as fraction.
      await Future.wait(result.map((w) async {
        try {
          final progress = await getProgressForWord(w.id);
          final correct = progress?.correctCount ?? 0;
          final frac = (correct * 0.1).clamp(0.0, 1.0);
          _progressMap[w.id] = frac;
        } catch (_) {
          _progressMap[w.id] = 0.0;
        }
      }));
      // Notify listeners so UI can refresh
      update();
    } finally {
      isLoading.value = false;
    }
  }

  // ⭐ Tính progress từ Progress entity (level 0-5 → 0-1)
  double getWordProgress(int wordId) {
    return _progressMap[wordId] ?? 0.0;
  }
}
