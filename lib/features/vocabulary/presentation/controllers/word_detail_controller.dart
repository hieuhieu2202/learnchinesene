import 'package:audioplayers/audioplayers.dart';
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
  final isPlayingAudio = false.obs;

  final AudioPlayer _player = AudioPlayer();

  @override
  void onInit() {
    super.onInit();
    loadWord();
  }

  @override
  void onClose() {
    _player.dispose();
    super.onClose();
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

  Future<void> playPronunciation() async {
    final current = word.value;
    if (current == null || current.ttsUrl.isEmpty) {
      Get.snackbar('Không có audio', 'Từ này chưa có tệp phát âm.');
      return;
    }

    try {
      isPlayingAudio.value = true;
      await _player.stop();
      await _player.play(UrlSource(current.ttsUrl));
    } catch (_) {
      Get.snackbar('Không phát được audio', 'Vui lòng thử lại sau.');
    } finally {
      isPlayingAudio.value = false;
    }
  }
}
