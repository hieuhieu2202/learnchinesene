import 'package:get/get.dart';

import '../../domain/entities/example_sentence.dart';
import '../../domain/entities/word.dart';
import '../../domain/usecases/get_examples_by_word.dart';
import '../../domain/usecases/get_word_by_id.dart';

class WordDetailController extends GetxController {
  WordDetailController({
    required this.wordId,
    required this.getWordById,
    required this.getExamplesByWord,
  });

  final int wordId;
  final GetWordById getWordById;
  final GetExamplesByWord getExamplesByWord;

  final word = Rxn<Word>();
  final examples = <ExampleSentence>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadWord();
  }

  Future<void> loadWord() async {
    isLoading.value = true;
    try {
      word.value = await getWordById(wordId);
      examples.assignAll(await getExamplesByWord(wordId));
    } finally {
      isLoading.value = false;
    }
  }
}
