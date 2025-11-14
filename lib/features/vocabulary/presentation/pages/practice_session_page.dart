import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/practice_session_controller.dart';
import '../theme/hsk_palette.dart';
import '../utils/hsk_utils.dart';
import '../widgets/practice_question_card.dart';

class PracticeSessionPage extends GetView<PracticeSessionController> {
  const PracticeSessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.questions.isEmpty) {
          return const _EmptyPracticeState();
        }

        if (controller.isFinished.value) {
          return _ResultView(controller: controller);
        }

        final question = controller.currentQuestion;
        if (question == null) {
          return const SizedBox.shrink();
        }

        final level = parseHskLevel(
          sectionId: question.word.sectionId,
          sectionTitle: question.word.sectionTitle,
        );
        final gradient = HskPalette.gradientForLevel(level);
        final progress =
            (controller.currentIndex.value + 1) / controller.questions.length;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [gradient.first, gradient.last, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _PracticeHeader(
                  controller: controller,
                  level: level,
                  progress: progress,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: PracticeQuestionCard(
                      key: ValueKey(controller.currentIndex.value),
                      question: question,
                      accentLevel: level,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _PracticeHeader extends StatelessWidget {
  const _PracticeHeader({
    required this.controller,
    required this.level,
    required this.progress,
  });

  final PracticeSessionController controller;
  final int level;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = HskPalette.accentForLevel(level, theme.colorScheme);
    final question = controller.currentQuestion;
    final stageLabel = _stageLabel(question?.stage);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question?.word.word ?? 'Luyện tập',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      stageLabel,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text('HSK $level'),
                labelStyle: theme.textTheme.labelMedium?.copyWith(color: accent),
                backgroundColor: accent.withOpacity(0.15),
                shape: const StadiumBorder(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: accent.withOpacity(0.15),
            color: accent,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 12),
          Text(
            'Câu ${controller.currentIndex.value + 1}/${controller.questions.length} • Điểm: ${controller.score.value}',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _stageLabel(PracticeMode? mode) {
    switch (mode) {
      case PracticeMode.typingMeaning:
        return 'Level 1 • Gõ nghĩa';
      case PracticeMode.typingPinyin:
        return 'Level 2 • Gõ Pinyin';
      case PracticeMode.typingHanzi:
        return 'Level 3 • Gõ chữ Hán';
      case PracticeMode.typingFillBlank:
        return 'Level 4 • Điền vào câu';
      case PracticeMode.typingSentence:
        return 'Level 5 • Gõ cả câu';
      default:
        return 'Luyện tập hành trình';
    }
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.controller});

  final PracticeSessionController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFDE7EF), Color(0xFFEFF9FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 26,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events, size: 72, color: Colors.amber),
                  const SizedBox(height: 16),
                  Text(
                    'Hoàn thành!',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Điểm số: ${controller.score.value}/${controller.questions.length}',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: controller.restart,
                    icon: const Icon(Icons.replay),
                    label: const Text('Luyện lại'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyPracticeState extends StatelessWidget {
  const _EmptyPracticeState();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFDE7EF), Color(0xFFEFF9FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.self_improvement_outlined, size: 72, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Chưa có dữ liệu luyện tập',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Hãy chọn bài học và thêm từ vào hành trình trước khi luyện.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
