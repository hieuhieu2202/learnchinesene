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

  final Exercise exercise;
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
  List<String> _selectedSegments = [];
  List<String> _availableSegments = [];
  late final Color accent;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<PracticeSessionController>();
    _textController = TextEditingController();
    _resetArrangeBuffers(widget.exercise);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    accent = HskPalette.accentForLevel(
        widget.accentLevel, Theme.of(context).colorScheme);
  }

  @override
  void didUpdateWidget(covariant PracticeQuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise != widget.exercise) {
      _textController.clear();
      _errorMessage = null;
      _showAnswer = false;
      _attempts = 0;
      _resetArrangeBuffers(widget.exercise);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _resetArrangeBuffers(Exercise exercise) {
    if (exercise.type != ExerciseType.typeArrangeSentence) {
      _selectedSegments = [];
      _availableSegments = [];
      return;
    }
    if (exercise is SentenceExercise) {
      final segments = exercise.arrangeSegments ?? [];
      final options = exercise.arrangeOptions ?? segments;
      _selectedSegments = [];
      _availableSegments = List<String>.from(options);
      // Shuffle once per question. Never shuffle inside build().
      _availableSegments.shuffle();
    } else {
      _selectedSegments = [];
      _availableSegments = [];
    }
  }

  Future<void> _handleCheck() async {
    final exercise = widget.exercise;
    if (exercise.type == ExerciseType.typeArrangeSentence) {
      if (_selectedSegments.isEmpty) {
        setState(() {
          _errorMessage = 'Vui lòng chọn các từ để tạo thành câu!';
        });
        return;
      }
      final success = await _controller.submitArrangeAnswer(_selectedSegments);
      if (!mounted) return;
      if (success) {
        setState(() {
          _errorMessage = null;
          _showAnswer = false;
          _attempts = 0;
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
      return;
    }
    // Handle typing exercises
    final success = await _controller.submitTypedAnswer(_textController.text);
    if (!mounted) return;
    if (success) {
      setState(() {
        _errorMessage = null;
        _showAnswer = false;
      });
    } else {
      setState(() {
        _errorMessage = 'Chưa đúng, thử lại nhé!';
        _attempts += 1;
      });
      if (_attempts >= 3) {
        await _controller.markWrong(advance: true);
        if (!mounted) return;
        setState(() {
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
  }

  void _handleShowAnswer() {
    setState(() {
      _showAnswer = true;
    });
  }

  Future<void> _handleSkip() async {
    await _controller.markWrong(advance: true);
    if (!mounted) return;
    setState(() {
      _errorMessage = null;
      _showAnswer = false;
      _attempts = 0;
    });
  }

  void _handleSegmentSelected(String segment) {
    setState(() {
      if (_selectedSegments.contains(segment)) {
        _selectedSegments.remove(segment);
        _availableSegments.add(segment);
      } else if (_availableSegments.contains(segment)) {
        _availableSegments.remove(segment);
        _selectedSegments.add(segment);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exercise = widget.exercise;
    // NOTE: Don't mutate state in build (no shuffle here).

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withAlpha(20),
              blurRadius: 24,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _TypingContent(
            exercise: exercise is SentenceExercise
                ? exercise
                : (exercise is MissingWordExercise
                    ? SentenceExercise(
                        type: exercise.type,
                        sentence: exercise.sentence,
                        correctAnswer: exercise.correctAnswer)
                    : SentenceExercise(
                        type: exercise.type,
                        sentence: PracticeSentence(
                            id: '',
                            baseExampleId: null,
                            mainWordId: 0,
                            chinese: '',
                            pinyin: '',
                            vietnamese: '',
                            isFromAI: false),
                        correctAnswer: '')),
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
            selectedSegments: _selectedSegments,
            availableSegments: _availableSegments,
            onSegmentSelected: _handleSegmentSelected,
          ),
        ),
      ),
    );
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
    required this.selectedSegments,
    required this.availableSegments,
    required this.onSegmentSelected,
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
  final List<String> selectedSegments;
  final List<String> availableSegments;
  final ValueChanged<String> onSegmentSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hintStyle = theme.textTheme.bodyMedium;
    final title = _titleForType(exercise.type, word);
    final prompt = _promptForType(exercise);
    final inputLabel = _inputLabelForType(exercise.type);
    final extraHints = _buildExtraHints(exercise);
    final isArrange = exercise.type == ExerciseType.typeArrangeSentence;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: accent.withAlpha(38),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  title,
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: accent, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Câu ${index + 1}/$total',
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            prompt,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),

          // Show correct answer when user taps “Xem đáp án”
          if (showAnswer) ...[
            const SizedBox(height: 12),
            _AnswerBanner(
              answer: exercise.correctAnswer,
              accent: accent,
            ),
          ],

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
          if (isArrange) ...[
            // Make selected area more flexible & taller
            _SelectedSegmentsArea(
              selectedSegments: selectedSegments,
              accent: accent,
              onSegmentSelected: onSegmentSelected,
            ),
            const SizedBox(height: 16),
            _ArrangeSentenceWidget(
              segments: availableSegments,
              selectedSegments: selectedSegments,
              onSegmentSelected: onSegmentSelected,
              accent: accent,
            ),
          ] else ...[
            TextField(
              controller: textController,
              maxLines: 2,
              autofocus: true,
              decoration: InputDecoration(
                labelText: inputLabel,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                errorText: errorMessage,
              ),
            ),
          ],
          const SizedBox(height: 20),
          // Make buttons less cramped on small screens
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onChecked,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Kiểm tra'),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onShowAnswer,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Xem đáp án'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onSkip,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Bỏ qua'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
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
      case ExerciseType.typeArrangeSentence:
        return 'Sắp xếp thành câu';
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
          exercise.correctAnswer,
          '___',
        );
      case ExerciseType.typeFullSentenceCopy:
        return '${sentence.vietnamese}\n\n(Hãy gõ lại câu tiếng Trung)';
      case ExerciseType.typeArrangeSentence:
        return 'Sắp xếp các từ thành câu đúng';
      case ExerciseType.typeTransformed:
        return sentence.chinese;
    }
  }

  String _inputLabelForType(ExerciseType type) {
    switch (type) {
      case ExerciseType.typeMissingWord:
        return 'Nhập từ còn thiếu';
      case ExerciseType.typeArrangeSentence:
        return 'Chọn các từ để tạo thành câu';
      default:
        return 'Gõ câu tiếng Trung tại đây';
    }
  }

  List<String> _buildExtraHints(SentenceExercise exercise) {
    final hints = <String>[];
    final vietnameseHint = exercise.sentence.vietnamese;
    if (exercise.type != ExerciseType.typeFromVietnamese &&
        vietnameseHint.isNotEmpty) {
      hints.add('Nghĩa: $vietnameseHint');
    }
    return hints;
  }
}

class _AnswerBanner extends StatelessWidget {
  const _AnswerBanner({
    required this.answer,
    required this.accent,
  });

  final String answer;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withAlpha(90), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Đáp án đúng',
            style: theme.textTheme.labelLarge?.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            answer.isEmpty ? '—' : answer,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedSegmentsArea extends StatelessWidget {
  const _SelectedSegmentsArea({
    required this.selectedSegments,
    required this.accent,
    required this.onSegmentSelected,
  });

  final List<String> selectedSegments;
  final Color accent;
  final ValueChanged<String> onSegmentSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: accent.withAlpha(77), width: 2),
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(77),
      ),
      child: selectedSegments.isEmpty
          ? Center(
              child: Text(
                'Chọn các từ bên dưới',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withAlpha(153),
                ),
              ),
            )
          : SingleChildScrollView(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: selectedSegments
                    .map(
                      (segment) => GestureDetector(
                        onTap: () => onSegmentSelected(segment),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: accent.withAlpha(51),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: accent, width: 2),
                          ),
                          child: Text(
                            segment,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
    );
  }
}

class _ArrangeSentenceWidget extends StatelessWidget {
  const _ArrangeSentenceWidget({
    required this.segments,
    required this.selectedSegments,
    required this.onSegmentSelected,
    required this.accent,
  });

  final List<String> segments;
  final List<String> selectedSegments;
  final ValueChanged<String> onSegmentSelected;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: segments
            .map(
              (segment) => GestureDetector(
                onTap: () => onSegmentSelected(segment),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: accent.withAlpha(38),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selectedSegments.contains(segment)
                          ? accent
                          : theme.colorScheme.onSurfaceVariant,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    segment,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: selectedSegments.contains(segment)
                          ? accent
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
