import 'package:get/get.dart';
import '../../../models/duo_flashcard.dart';
import '../../../database/duo_db_helper.dart';

class DuoFlashcardController extends GetxController {
  final isLoading = true.obs;
  final flashcards = <DuoFlashcard>[].obs;
  final currentIndex = 0.obs;
  final showMeaning = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFlashcards();
  }

  Future<void> loadFlashcards() async {
    isLoading.value = true;
    final cards = await DuoDbHelper.instance.getRandomFlashcards(limit: 20);
    flashcards.assignAll(cards);
    currentIndex.value = 0;
    showMeaning.value = false;
    isLoading.value = false;
  }

  void nextCard() {
    if (currentIndex.value < flashcards.length - 1) {
      currentIndex.value++;
      showMeaning.value = false;
    } else {
      loadFlashcards(); // Load batch mới
    }
  }

  void toggleMeaning() {
    showMeaning.value = !showMeaning.value;
  }
}
