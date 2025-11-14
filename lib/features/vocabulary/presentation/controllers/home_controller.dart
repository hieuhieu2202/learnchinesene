import 'package:get/get.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../domain/usecases/get_sections.dart';
import '../../../domain/usecases/get_words_to_review_today.dart';

class HomeController extends GetxController {
  HomeController({
    required this.getWordsToReviewToday,
    required this.getSections,
  });

  final GetWordsToReviewToday getWordsToReviewToday;
  final GetSections getSections;

  final reviewCount = 0.obs;
  final currentSectionId = 1.obs;
  final sections = <int>[].obs;
  final isLoading = false.obs;

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
      sections.assignAll(await getSections(NoParams()));
      if (sections.isNotEmpty) {
        currentSectionId.value = sections.first;
      }
    } finally {
      isLoading.value = false;
    }
  }
}
