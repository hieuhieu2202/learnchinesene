import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/gemini_service.dart';
import '../../../services/history_service.dart';

class TranslatorController extends GetxController {
  final GeminiService _gemini = Get.find<GeminiService>();
  final HistoryService _history = Get.find<HistoryService>();
  final FlutterTts _tts = FlutterTts();

  final inputController = TextEditingController();
  final isLoading = false.obs;
  final hasResult = false.obs;

  // Translation result fields
  final sourceLang = ''.obs;
  final targetLang = ''.obs;
  final hanzi = ''.obs;
  final pinyin = ''.obs;
  final viMeaning = ''.obs;
  final examples = <Map<String, String>>[].obs;
  final grammarNotes = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('zh-CN');
    await _tts.setSpeechRate(0.85);
  }

  Future<void> speak(String text) async {
    if (text.trim().isNotEmpty) {
      await _tts.speak(text);
    }
  }

  Future<void> translateText() async {
    final query = inputController.text.trim();
    if (query.isEmpty) return;

    isLoading.value = true;
    hasResult.value = false;

    try {
      final res = await _gemini.translate(query);

      sourceLang.value = res['source_lang'] ?? '';
      targetLang.value = res['target_lang'] ?? '';
      hanzi.value = res['hanzi'] ?? '';
      pinyin.value = res['pinyin'] ?? '';
      viMeaning.value = res['vi_meaning'] ?? '';

      final rawExamples = res['examples'] as List<dynamic>? ?? [];
      examples.value = rawExamples.map((e) {
        final map = e as Map<dynamic, dynamic>;
        return {
          'zh': map['zh']?.toString() ?? '',
          'pinyin': map['pinyin']?.toString() ?? '',
          'vi': map['vi']?.toString() ?? '',
        };
      }).toList();

      final rawNotes = res['grammar_notes'] as List<dynamic>? ?? [];
      grammarNotes.value = rawNotes.map((e) => e.toString()).toList();

      hasResult.value = true;

      // Save to History
      await _history.saveHistory(
        HistoryItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: 'Dịch thuật',
          timestamp: DateTime.now().toIso8601String(),
          summary: query.length > 30 ? '${query.substring(0, 30)}...' : query,
          content: res,
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể hoàn thành dịch thuật. Vui lòng kiểm tra lại kết nối.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickAndTranslateImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (image == null) return;

    isLoading.value = true;
    hasResult.value = false;

    try {
      final Uint8List bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      final ext = image.path.split('.').last.toLowerCase();
      final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';

      final extractedText =
          await _gemini.extractTextFromImage(base64Image, mimeType);

      if (extractedText.trim().isEmpty) {
        Get.snackbar('Thông báo', 'Không tìm thấy chữ Hán nào trong ảnh.');
        return;
      }

      inputController.text = extractedText;
      await translateText();
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể nhận diện chữ từ ảnh. Vui lòng chọn ảnh khác rõ nét hơn.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    inputController.dispose();
    _tts.stop();
    super.onClose();
  }
}
