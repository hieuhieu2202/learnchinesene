import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_colors.dart';
import '../../services/gemini_service.dart';
import '../../services/history_service.dart';
import '../../core/responsive/responsive_layout.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TextEditingController _inputController = TextEditingController();
  final GeminiService _gemini = GeminiService();
  final HistoryService _history = Get.find<HistoryService>();
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isLoading = false;
  String _error = '';
  Map<String, dynamic>? _result;

  bool _isListening = false;
  String _recognitionLang = 'vi-VN';
  String _recognitionError = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      await _speech.initialize();
    } catch (_) {}
  }

  @override
  void dispose() {
    _inputController.dispose();
    _tts.stop();
    _speech.stop();
    super.dispose();
  }

  Future<void> _handleSearch() async {
    final word = _inputController.text.trim();
    if (word.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = '';
      _result = null;
    });

    try {
      final entry = await _gemini.fetchDictionaryEntry(word);
      setState(() {
        _result = entry;
      });

      // Save to history log
      final summary = 'Đã tra từ: "$word"';
      await _history.saveHistory(
        HistoryItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: 'Từ điển',
          timestamp: DateTime.now().toIso8601String(),
          summary: summary,
          content: entry,
        ),
      );
    } catch (e) {
      setState(() {
        _error = 'Không thể tra cứu từ này. Vui lòng thử lại.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _playAudio(String text) async {
    try {
      await _tts.setLanguage('zh-CN');
      await _tts.setSpeechRate(0.4);
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> _handleListen() async {
    var status = await Permission.microphone.status;
    if (status.isDenied) {
      status = await Permission.microphone.request();
      if (status.isDenied) {
        setState(() {
          _recognitionError = 'Chưa được cấp quyền sử dụng Micro.';
        });
        return;
      }
    }

    if (_isListening) {
      await _speech.stop();
      setState(() {
        _isListening = false;
      });
      return;
    }

    final isAvailable = await _speech.initialize();
    if (!isAvailable) {
      setState(() {
        _recognitionError = 'Nhận giọng nói không khả dụng.';
      });
      return;
    }

    setState(() {
      _isListening = true;
      _recognitionError = '';
    });

    await _speech.listen(
      localeId: _recognitionLang,
      onResult: (result) {
        if (result.finalResult) {
          setState(() {
            _inputController.text = result.recognizedWords;
            _isListening = false;
          });
          _handleSearch();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxWidth = ResponsiveHelper.contentMaxWidth(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Từ điển Việt ↔ Trung',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Search input container
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _inputController,
                              decoration: InputDecoration(
                                hintText:
                                    'Nhập từ cần tra (tiếng Việt hoặc Trung)...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: theme.colorScheme.surfaceVariant
                                    .withAlpha(80),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              onSubmitted: (_) => _handleSearch(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          FilledButton(
                            onPressed: _isLoading ? null : _handleSearch,
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Tra từ'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          IconButton.filled(
                            onPressed: _handleListen,
                            style: IconButton.styleFrom(
                              backgroundColor: _isListening
                                  ? AppColors.error
                                  : theme.colorScheme.primary,
                            ),
                            icon: Icon(
                              _isListening
                                  ? Icons.stop_rounded
                                  : Icons.mic_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          DropdownButton<String>(
                            value: _recognitionLang,
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(
                                value: 'vi-VN',
                                child: Text('Nói Tiếng Việt'),
                              ),
                              DropdownMenuItem(
                                value: 'zh-CN',
                                child: Text('说中文 (zh-CN)'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _recognitionLang = val;
                                });
                              }
                            },
                          ),
                          if (_recognitionError.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _recognitionError,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (_error.isNotEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      _error,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ),

              if (_result != null) _buildResultView(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultView(ThemeData theme) {
    final hanzi = _result!['hanzi'] ?? '';
    final pinyin = _result!['pinyin'] ?? '';
    final viMeaning = _result!['vi_meaning'] ?? '';
    final examples = _result!['examples'] as List<dynamic>? ?? [];
    final grammarNotes = _result!['grammar_notes'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Word Card
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.05),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.redDark,
                  AppColors.red,
                  AppColors.orange,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      hanzi,
                      style: const TextStyle(
                        fontFamily: 'FZKaiTiPinyin',
                        fontSize: 52,
                        color: Colors.white,
                      ),
                    ),
                    IconButton.filled(
                      onPressed: () => _playAudio(hanzi),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.red,
                      ),
                      icon: const Icon(Icons.volume_up_rounded),
                    ),
                  ],
                ),
                Text(
                  pinyin,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  viMeaning,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Examples
        if (examples.isNotEmpty) ...[
          const Text(
            'Ví dụ đặt câu:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          ...examples.map((ex) {
            final zh = ex['zh'] ?? '';
            final py = ex['pinyin'] ?? '';
            final vi = ex['vi'] ?? '';
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            zh,
                            style: const TextStyle(
                              fontFamily: 'FZKaiTiPinyin',
                              fontSize: 22,
                            ),
                          ),
                          Text(
                            py,
                            style: const TextStyle(
                              color: AppColors.orange,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            vi,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _playAudio(zh),
                      icon: const Icon(
                        Icons.volume_up_rounded,
                        color: AppColors.red,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],

        const SizedBox(height: 16),

        // Grammar / synonyms
        if (grammarNotes.isNotEmpty) ...[
          const Text(
            'Ghi chú / Từ liên quan:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: grammarNotes.map((note) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Text(
                            note.toString(),
                            style: const TextStyle(height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
