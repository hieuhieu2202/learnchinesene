import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/practice_models.dart';
import '../../domain/entities/word.dart';
import '../controllers/practice_session_controller.dart';
import '../theme/hsk_palette.dart';

class PracticeQuestionCard extends StatefulWidget {
  const PracticeQuestionCard({
    super.key,
    required this.exercise,
    required this.word,
    required this.accentLevel,
    required this.index,
    required this.total,
  });

  final SentenceExercise exercise;
  final Word? word;
  final int accentLevel;
  final int index;
  final int total;

  @override
  State<PracticeQuestionCard> createState() => _PracticeQuestionCardState();
}

class _PracticeQuestionCardState extends State<PracticeQuestionCard> {
  late final PracticeSessionController _controller;
  late final TextEditingController _textController;
  String? _errorMessage;
  bool _showAnswer = false;
  int _attempts = 0;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<PracticeSessionController>();
    _textController = TextEditingController();
  }

  @override
  void didUpdateWidget(covariant PracticeQuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise != widget.exercise) {
      _textController.clear();
      _errorMessage = null;
      _showAnswer = false;
      _attempts = 0;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = HskPalette.accentForLevel(widget.accentLevel, theme.colorScheme);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            colors: [theme.colorScheme.surface, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.12),
              blurRadius: 28,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _TypingContent(
            exercise: widget.exercise,
            word: widget.word,
            index: widget.index,
            total: widget.total,
            textController: _textController,
            errorMessage: _errorMessage,
            showAnswer: _showAnswer,
            onChecked: _handleCheck,
            onShowAnswer: _handleShowAnswer,
            onSkip: _handleSkip,
            accent: accent,
          ),
        ),
      ),
    );
  }

  Future<void> _handleCheck() async {
    final success = await _controller.submitTypedAnswer(_textController.text);
    if (!mounted) return;
    if (success) {
      setState(() {
        _errorMessage = null;
        _showAnswer = false;
        _attempts = 0;
        _textController.clear();
      });
      return;
    }

    setState(() {
      _errorMessage = 'Chưa đúng, thử lại nhé!';
      _attempts += 1;
    });

    if (_attempts >= 3) {
      await _controller.markWrong(advance: true);
      if (!mounted) return;
      setState(() {
        _textController.clear();
        _errorMessage = null;
        _showAnswer = false;
        _attempts = 0;
      });
      Get.snackbar(
        'Chuyển bài',
        'Sai 3 lần rồi, chuyển sang câu tiếp theo nhé!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _handleShowAnswer() {
    setState(() {
      _showAnswer = true;
      _errorMessage = null;
    });
  }

  Future<void> _handleSkip() async {
    await _controller.skipCurrent();
    if (!mounted) return;
    setState(() {
      _textController.clear();
      _errorMessage = null;
      _showAnswer = false;
      _attempts = 0;
    });
  }
}

class _TypingContent extends StatelessWidget {
  const _TypingContent({
    required this.exercise,
    required this.word,
    required this.index,
    required this.total,
    required this.textController,
    required this.errorMessage,
    required this.showAnswer,
    required this.onChecked,
    required this.onShowAnswer,
    required this.onSkip,
    required this.accent,
  });

  final SentenceExercise exercise;
  final Word? word;
  final int index;
  final int total;
  final TextEditingController textController;
  final String? errorMessage;
  final bool showAnswer;
  final Future<void> Function() onChecked;
  final VoidCallback onShowAnswer;
  final Future<void> Function() onSkip;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hintStyle = theme.textTheme.bodyMedium;
    final title = _titleForType(exercise.type, word);
    final prompt = _promptForType(exercise);
    final inputLabel = _inputLabelForType(exercise.type);
    final extraHints = _buildExtraHints(exercise);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(color: accent, fontWeight: FontWeight.w700),
              ),
            ),
            const Spacer(),
            Text(
              'Câu ${index + 1}/$total',
              style: theme.textTheme.labelMedium,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          prompt,
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (extraHints.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...extraHints.map(
            (extra) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(extra, style: hintStyle),
            ),
          ),
        ],
        const SizedBox(height: 20),
        TextField(
          controller: textController,
          minLines: exercise.type == ExerciseType.typeMissingWord ? 1 : 2,
          maxLines: 5,
          autofocus: true,
          decoration: InputDecoration(
            labelText: inputLabel,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            errorText: errorMessage,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: onChecked,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Kiểm tra'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: onShowAnswer,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Xem đáp án'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onSkip,
            child: const Text('Bỏ qua'),
          ),
        ),
        if (showAnswer) ...[
          const Divider(height: 32),
          Text(
            'Đáp án đúng',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          SelectableText(
            _answerText(exercise),
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text('Pinyin: ${exercise.sentence.pinyin}', style: hintStyle),
          const SizedBox(height: 4),
          Text('Nghĩa: ${exercise.sentence.vietnamese}', style: hintStyle),
        ],
      ],
    );
  }

  String _titleForType(ExerciseType type, Word? word) {
    final wordLabel = word?.word ?? '';
    switch (type) {
      case ExerciseType.typeFromVietnamese:
        return 'Từ nghĩa → gõ câu';
      case ExerciseType.typeFromPinyin:
        return 'Từ pinyin → gõ câu';
      case ExerciseType.typeMissingWord:
        return 'Điền từ "$wordLabel"';
      case ExerciseType.typeFullSentenceCopy:
        return 'Chép lại câu tiếng Trung';
      case ExerciseType.typeTransformed:
        return 'Câu biến đổi/AI';
    }
  }

  String _promptForType(SentenceExercise exercise) {
    final sentence = exercise.sentence;
    switch (exercise.type) {
      case ExerciseType.typeFromVietnamese:
        return sentence.vietnamese;
      case ExerciseType.typeFromPinyin:
        return sentence.pinyin;
      case ExerciseType.typeMissingWord:
        return sentence.chinese.replaceFirst(
          exercise.hiddenWord ?? '',
          '___',
        );
      case ExerciseType.typeFullSentenceCopy:
        return sentence.vietnamese;
      case ExerciseType.typeTransformed:
        return '${sentence.vietnamese}\n\n(Hãy gõ lại câu tiếng Trung)';
    }
  }

  String _inputLabelForType(ExerciseType type) {
    switch (type) {
      case ExerciseType.typeMissingWord:
        return 'Nhập từ còn thiếu';
      default:
        return 'Gõ câu tiếng Trung tại đây';
    }
  }

  List<String> _buildExtraHints(SentenceExercise exercise) {
    final hints = <String>[];
    if (exercise.type != ExerciseType.typeFromPinyin) {
      hints.add('Pinyin: ${exercise.sentence.pinyin}');
    }
    if (exercise.type != ExerciseType.typeFromVietnamese) {
      hints.add('Nghĩa: ${exercise.sentence.vietnamese}');
    }
    if (exercise.type == ExerciseType.typeMissingWord && exercise.hintPinyin != null) {
      hints.add('Gợi ý pinyin từ: ${exercise.hintPinyin}');
    }
    return hints;
  }

  String _answerText(SentenceExercise exercise) {
    if (exercise.type == ExerciseType.typeMissingWord) {
      return exercise.correctAnswer;
    }
    return exercise.sentence.chinese;
  }
}
