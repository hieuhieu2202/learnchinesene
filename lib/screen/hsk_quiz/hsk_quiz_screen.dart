import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../core/theme/app_colors.dart';
import '../../services/gemini_service.dart';
import '../../core/responsive/responsive_layout.dart';
import 'package:get/get.dart';
import '../../features/subscription/controller/subscription_controller.dart';
import '../../core/helper/upgrade_dialog_helper.dart';

class HskQuizScreen extends StatefulWidget {
  const HskQuizScreen({super.key});

  @override
  State<HskQuizScreen> createState() => _HskQuizScreenState();
}

enum QuizState { setup, playing, finished }

class _HskQuizScreenState extends State<HskQuizScreen> {
  final GeminiService _gemini = GeminiService();
  final FlutterTts _tts = FlutterTts();

  int _selectedLevel = 1;
  QuizState _state = QuizState.setup;
  List<dynamic> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  List<String?> _userAnswers = [];
  bool _isLoading = false;
  String? _selectedAnswer;

  Future<void> _generateQuestions() async {
    setState(() {
      _isLoading = true;
      _state = QuizState.setup;
    });

    try {
      final allWords =
          await _gemini.fetchHskVocabulary(_selectedLevel, count: 40);

      if (allWords.length < 10) {
        throw Exception('Không đủ từ vựng để tạo bài thi.');
      }

      // Generate 10 random questions
      allWords.shuffle();
      final wordsForQuiz = allWords.take(10).toList();

      final List<dynamic> generatedQuestions = [];
      final random = math.Random();

      for (var word in wordsForQuiz) {
        // Types: 0: meaning, 1: hanzi, 2: pinyin
        final typeIndex = random.nextInt(3);
        final String correctAnswer;
        final String questionText;
        final String matchProperty;

        if (typeIndex == 0) {
          questionText = 'Nghĩa của "${word['hanzi']}" là gì?';
          correctAnswer = word['meaning_vi'] ?? '';
          matchProperty = 'meaning_vi';
        } else if (typeIndex == 1) {
          questionText = 'Từ nào có nghĩa là "${word['meaning_vi']}"?';
          correctAnswer = word['hanzi'] ?? '';
          matchProperty = 'hanzi';
        } else {
          questionText = 'Pinyin của "${word['hanzi']}" là gì?';
          correctAnswer = word['pinyin'] ?? '';
          matchProperty = 'pinyin';
        }

        // Build distractors
        final List<String> distractors = allWords
            .where((w) => w[matchProperty] != correctAnswer)
            .map((w) => (w[matchProperty] as String? ?? ''))
            .where((str) => str.isNotEmpty)
            .toList();

        distractors.shuffle();
        final List<String> options = distractors.take(3).toList();
        options.add(correctAnswer);
        options.shuffle();

        generatedQuestions.add({
          'word': word,
          'questionText': questionText,
          'correctAnswer': correctAnswer,
          'options': options,
          'typeIndex': typeIndex,
        });
      }

      setState(() {
        _questions = generatedQuestions;
        _currentIndex = 0;
        _score = 0;
        _userAnswers = List.filled(10, null);
        _state = QuizState.playing;
        _selectedAnswer = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Lỗi tải bài trắc nghiệm HSK $_selectedLevel. Vui lòng thử lại.'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleAnswer(String answer) {
    if (_selectedAnswer != null) return;

    setState(() {
      _selectedAnswer = answer;
      _userAnswers[_currentIndex] = answer;
      if (answer == _questions[_currentIndex]['correctAnswer']) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
      });
    } else {
      setState(() {
        _state = QuizState.finished;
      });
    }
  }

  Future<void> _playTts(String text) async {
    try {
      await _tts.setLanguage('zh-CN');
      await _tts.speak(text);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxWidth = ResponsiveHelper.contentMaxWidth(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trắc nghiệm từ vựng HSK',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildBody(theme),
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    switch (_state) {
      case QuizState.setup:
        return _buildSetupView(theme);
      case QuizState.playing:
        return _buildPlayingView(theme);
      case QuizState.finished:
        return _buildFinishedView(theme);
    }
  }

  Widget _buildSetupView(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.quiz_rounded, size: 80, color: AppColors.red),
          const SizedBox(height: 18),
          const Text(
            'Chọn cấp độ để bắt đầu trắc nghiệm',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: List.generate(6, (i) {
              final level = i + 1;
              final isSelected = _selectedLevel == level;
              final subController = Get.find<SubscriptionController>();
              final isUnlocked = subController.isLevelUnlocked(level);

              return ChoiceChip(
                selected: isSelected,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'HSK $level',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    if (!isUnlocked) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.lock_rounded, size: 14, color: AppColors.orange),
                    ],
                  ],
                ),
                onSelected: (selected) {
                  if (selected) {
                    if (isUnlocked) {
                      setState(() {
                        _selectedLevel = level;
                      });
                    } else {
                      UpgradeDialogHelper.showUpgradeDialog(
                        context: context,
                        title: 'Mở khóa Trắc nghiệm HSK $level',
                        message: 'Bài trắc nghiệm cấp độ HSK $level yêu cầu nâng cấp gói cước để truy cập.',
                        benefits: level <= 3
                            ? ['Luyện tập trắc nghiệm HSK 1-3', 'Lưu tiến độ trên đám mây']
                            : ['Luyện tập trắc nghiệm HSK 1-6', 'Hội thoại AI không giới hạn', 'Thi thử HSK với AI'],
                      );
                    }
                  }
                },
                selectedColor: AppColors.red.withOpacity(0.2),
                checkmarkColor: AppColors.red,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.red : Colors.black87,
                ),
              );
            }),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _generateQuestions,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.play_circle_fill_rounded),
            label: const Text(
              'Bắt đầu học',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayingView(ThemeData theme) {
    final q = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;
    final options = q['options'] as List<dynamic>;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Câu hỏi ${_currentIndex + 1} / ${_questions.length}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.muted),
              ),
              Text(
                'Đúng: $_score',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.success),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceVariant,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.red),
            ),
          ),
          const SizedBox(height: 32),

          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.04),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    q['questionText'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800, height: 1.3),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filled(
                        onPressed: () => _playTts(q['word']['hanzi'] ?? ''),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.red.withOpacity(0.1),
                          foregroundColor: AppColors.red,
                        ),
                        icon: const Icon(Icons.volume_up_rounded),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Phát âm từ vựng',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.muted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Options Grid
          Expanded(
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (context, idx) {
                final opt = options[idx];
                final isSelected = _selectedAnswer == opt;
                final isCorrectOpt = opt == q['correctAnswer'];

                Color btnBg = Colors.white;
                Color textCol = Colors.black87;
                BorderSide border = BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.2));

                if (_selectedAnswer != null) {
                  if (isCorrectOpt) {
                    btnBg = const Color(0xFFE7F7F0);
                    textCol = AppColors.success;
                    border =
                        const BorderSide(color: AppColors.success, width: 2);
                  } else if (isSelected) {
                    btnBg = const Color(0xFFFFE9E7);
                    textCol = AppColors.error;
                    border = const BorderSide(color: AppColors.error, width: 2);
                  }
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OutlinedButton(
                    onPressed: () => _handleAnswer(opt),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: btnBg,
                      side: border,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                      alignment: Alignment.centerLeft,
                    ),
                    child: Text(
                      opt,
                      style: TextStyle(
                        fontSize: 16,
                        color: textCol,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_selectedAnswer != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _nextQuestion,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentIndex + 1 == _questions.length
                          ? 'Xem kết quả'
                          : 'Câu tiếp theo',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFinishedView(ThemeData theme) {
    final percent = (_score / _questions.length * 100).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            elevation: 6,
            shadowColor: Colors.black.withOpacity(0.06),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  const Icon(Icons.emoji_events_rounded,
                      size: 72, color: AppColors.orange),
                  const SizedBox(height: 16),
                  Text(
                    '$percent%',
                    style: const TextStyle(
                        fontSize: 54,
                        fontWeight: FontWeight.w900,
                        color: AppColors.red),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bạn đã hoàn thành bài thi HSK $_selectedLevel',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.muted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Đúng $_score / ${_questions.length} câu',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Study Recommendations
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb_outline_rounded,
                          color: AppColors.orange),
                      SizedBox(width: 8),
                      Text(
                        'Từ vựng cần ôn lại:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_score == _questions.length)
                    const Text(
                        'Tuyệt vời! Bạn đã trả lời đúng tất cả các câu hỏi.')
                  else
                    ..._questions.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final q = entry.value;
                      final word = q['word'];
                      if (_userAnswers[idx] == q['correctAnswer']) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 15,
                                      height: 1.4),
                                  children: [
                                    TextSpan(
                                      text: '${word['hanzi']} ',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.red),
                                    ),
                                    TextSpan(
                                      text: '(${word['pinyin']}) - ',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.orange),
                                    ),
                                    TextSpan(text: word['meaning_vi']),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _state = QuizState.setup;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Cấp độ khác',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _generateQuestions,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Làm lại',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
