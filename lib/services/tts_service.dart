import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

/// Shared TTS service for the whole app.
///
/// Keeping a single FlutterTts instance prevents controllers/screens from
/// repeatedly binding and unbinding the Android TTS engine.
class TtsService extends GetxService {
  final FlutterTts _tts = FlutterTts();

  Future<bool>? _initializing;
  bool _ready = false;

  bool get isReady => _ready;

  Future<bool> ensureReady() {
    if (_ready) return Future.value(true);
    return _initializing ??= _initialize();
  }

  Future<bool> _initialize() async {
    try {
      await _tts.awaitSpeakCompletion(true);

      // Android can need a short moment to bind the system TTS engine.
      for (var attempt = 0; attempt < 3; attempt++) {
        try {
          final available = await _tts.isLanguageAvailable('zh-CN');
          if (available == true) {
            await _tts.setLanguage('zh-CN');
            await _tts.setSpeechRate(0.45);
            await _tts.setPitch(1.0);
            await _tts.setVolume(1.0);
            _ready = true;
            return true;
          }
        } catch (_) {
          // Retry below while Android finishes binding to the TTS engine.
        }

        await Future<void>.delayed(
          Duration(milliseconds: 250 * (attempt + 1)),
        );
      }
    } catch (_) {
      _ready = false;
    } finally {
      _initializing = null;
    }

    return false;
  }

  Future<void> speakChinese(String text) async {
    final value = text.trim();
    if (value.isEmpty) return;

    final ready = await ensureReady();
    if (!ready) {
      Get.snackbar(
        'Không thể phát âm thanh',
        'Thiết bị chưa sẵn sàng Text-to-Speech. Hãy kiểm tra công cụ TTS trong cài đặt hệ thống.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    try {
      await _tts.stop();
      await _tts.speak(value);
    } catch (_) {
      _ready = false;
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {
      // Ignore stop errors while the Android engine is rebinding.
    }
  }

  @override
  void onClose() {
    _tts.stop();
    super.onClose();
  }
}
