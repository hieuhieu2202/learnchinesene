import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/practice_session_controller.dart';
import '../theme/hsk_palette.dart';

class PracticeQuestionCard extends StatefulWidget {
  const PracticeQuestionCard({
    super.key,
    required this.question,
    required this.accentLevel,
  });

  final PracticeQuestion question;
  final int accentLevel;

  @override
  State<PracticeQuestionCard> createState() => _PracticeQuestionCardState();
}

class _PracticeQuestionCardState extends State<PracticeQuestionCard> {
  late final PracticeSessionController _controller;
  late final TextEditingController _textController;
  String? _errorMessage;
  bool _showAnswer = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<PracticeSessionController>();
    _textController = TextEditingController();
  }

  @override
  void didUpdateWidget(covariant PracticeQuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question != widget.question) {
      _textController.clear();
      _errorMessage = null;
      _showAnswer = false;
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
            question: widget.question,
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
    setState(() {
      _errorMessage = success ? null : 'Chưa đúng, thử lại nhé!';
      if (success) {
        _textController.clear();
        _showAnswer = false;
      }
    });
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
    });
  }
}

class _TypingContent extends StatelessWidget {
  const _TypingContent({
    required this.question,
    required this.textController,
    required this.errorMessage,
    required this.showAnswer,
    required this.onChecked,
    required this.onShowAnswer,
    required this.onSkip,
    required this.accent,
  });

  final PracticeQuestion question;
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
                question.title,
                style: theme.textTheme.labelLarge?.copyWith(color: accent, fontWeight: FontWeight.w700),
              ),
            ),
            const Spacer(),
            Text(
              'Mục tiêu Level ${question.targetLevel}',
              style: theme.textTheme.labelMedium,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          question.prompt,
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (question.hint != null) ...[
          const SizedBox(height: 12),
          Text(
            question.hint!,
            style: hintStyle,
          ),
        ],
        if (question.extraHints.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...question.extraHints.map(
            (extra) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(extra, style: hintStyle),
            ),
          ),
        ],
        const SizedBox(height: 20),
        TextField(
          controller: textController,
          minLines: 2,
          maxLines: 5,
          autofocus: true,
          decoration: InputDecoration(
            labelText: question.inputLabel,
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
            question.answer,
            style: theme.textTheme.titleLarge,
          ),
          if (question.example != null) ...[
            const SizedBox(height: 8),
            Text(
              'Pinyin: ${question.example!.sentencePinyin}',
              style: hintStyle,
            ),
            const SizedBox(height: 4),
            Text(
              'Nghĩa: ${question.example!.sentenceVi}',
              style: hintStyle,
            ),
          ],
        ],
      ],
    );
  }
}
