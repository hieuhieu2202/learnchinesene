import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
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
  final FlutterTts _tts = FlutterTts();

  @override
  void onInit() {
    super.onInit();
    _configureTts();
    loadWord();
  }

  Future<void> _configureTts() async {
    try {
      await _tts.setLanguage('zh-CN');
      await _tts.setSpeechRate(0.42);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
    } catch (_) {}
  }

  @override
  void onClose() {
    _player.dispose();
    _tts.stop();
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
    if (current == null || current.word.trim().isEmpty) return;

    isPlayingAudio.value = true;
    try {
      await _player.stop();

      if (current.ttsUrl.trim().isNotEmpty) {
        try {
          await _player.play(UrlSource(current.ttsUrl));
          return;
        } catch (_) {
          // Fall back to system Chinese TTS when the remote audio is missing
          // or temporarily unavailable.
        }
      }

      await _tts.stop();
      await _tts.speak(current.word);
    } catch (_) {
      Get.snackbar(
        'Không phát được âm thanh',
        'Thiết bị chưa có giọng đọc tiếng Trung hoặc mạng đang lỗi.',
      );
    } finally {
      isPlayingAudio.value = false;
    }
  }
}
