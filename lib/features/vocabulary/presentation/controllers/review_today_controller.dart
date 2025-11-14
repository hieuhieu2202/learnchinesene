import 'package:get/get.dart';

import '../../domain/entities/word.dart';
import '../../domain/usecases/get_word_by_id.dart';
import '../../domain/usecases/get_words_to_review_today.dart';

class ReviewTodayController extends GetxController {
  ReviewTodayController({
    required this.getWordsToReviewToday,
    required this.getWordById,
  });

  final GetWordsToReviewToday getWordsToReviewToday;
  final GetWordById getWordById;

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
      final today = DateTime.now();
      final wordIds = await getWordsToReviewToday(today);
      final result = <Word>[];
      for (final id in wordIds) {
        final word = await getWordById(id);
        if (word != null) {
          result.add(word);
        }
      }
      words.assignAll(result);
    } finally {
      isLoading.value = false;
    }
  }
}
