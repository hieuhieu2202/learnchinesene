import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/practice_session_controller.dart';

class PracticeQuestionCard extends StatefulWidget {
  const PracticeQuestionCard({
    super.key,
    required this.question,
  });

  final PracticeQuestion question;

  @override
  State<PracticeQuestionCard> createState() => _PracticeQuestionCardState();
}

class _PracticeQuestionCardState extends State<PracticeQuestionCard> {
  late final PracticeSessionController _controller;
  late final TextEditingController _textController;
  String? _errorMessage;
  bool _showAnswer = false;

  bool get _isTypingMode => _controller.isTypingMode;

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
      _textController.text = '';
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _isTypingMode
              ? _TypingContent(
                  question: widget.question,
                  controller: _controller,
                  textController: _textController,
                  errorMessage: _errorMessage,
                  showAnswer: _showAnswer,
                  onChecked: _handleCheck,
                  onShowAnswer: _handleShowAnswer,
                  onSkip: _handleSkip,
                )
              : _StandardContent(question: widget.question),
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

class _StandardContent extends StatelessWidget {
  const _StandardContent({required this.question});

  final PracticeQuestion question;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          question.prompt,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Text(
          question.answer,
          style: const TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
        if (question.hint != null) ...[
          const SizedBox(height: 16),
          Text(
            'Gợi ý: ${question.hint}',
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class _TypingContent extends StatelessWidget {
  const _TypingContent({
    required this.question,
    required this.controller,
    required this.textController,
    required this.errorMessage,
    required this.showAnswer,
    required this.onChecked,
    required this.onShowAnswer,
    required this.onSkip,
  });

  final PracticeQuestion question;
  final PracticeSessionController controller;
  final TextEditingController textController;
  final String? errorMessage;
  final bool showAnswer;
  final Future<void> Function() onChecked;
  final VoidCallback onShowAnswer;
  final Future<void> Function() onSkip;

  @override
  Widget build(BuildContext context) {
    final inputLabel = controller.mode == PracticeMode.typingPinyin
        ? 'Nhập lại câu bằng pinyin'
        : 'Nhập lại câu bằng chữ Hán';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          question.prompt,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        if (question.hint != null) ...[
          const SizedBox(height: 12),
          Text(
            'Gợi ý nghĩa: ${question.hint}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
        const SizedBox(height: 16),
        TextField(
          controller: textController,
          minLines: 3,
          maxLines: 5,
          autofocus: true,
          decoration: InputDecoration(
            labelText: inputLabel,
            border: const OutlineInputBorder(),
            errorText: errorMessage,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: () {
                  onChecked();
                },
                child: const Text('Kiểm tra'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  onShowAnswer();
                },
                child: const Text('Xem đáp án'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              onSkip();
            },
            child: const Text('Bỏ qua'),
          ),
        ),
        if (showAnswer) ...[
          const Divider(),
          Text(
            'Đáp án đúng:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SelectableText(
            question.answer,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ],
    );
  }
}
