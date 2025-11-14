import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/practice_models.dart';
import '../../domain/entities/word.dart';
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

        final total = controller.totalExercises;
        if (total == 0) {
          return const _EmptyPracticeState();
        }

        if (controller.isFinished.value) {
          return _ResultView(controller: controller);
        }

        final exercise = controller.currentExercise.value;
        if (exercise == null) {
          return const SizedBox.shrink();
        }

        final word = controller.currentWord;
        final level = parseHskLevel(
          sectionId: word?.sectionId ?? 0,
          sectionTitle: word?.sectionTitle ?? '',
        );
        final gradient = HskPalette.gradientForLevel(level);
        final scheme = Theme.of(context).colorScheme;
        final progress = total == 0
            ? 0.0
            : (controller.currentIndex.value + 1) / total;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                gradient.first,
                gradient.last,
                scheme.surface,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _PracticeHeader(
                  controller: controller,
                  word: word,
                  level: level,
                  progress: progress,
                  total: total,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: PracticeQuestionCard(
                      key: ValueKey(controller.currentIndex.value),
                      exercise: exercise,
                      word: word,
                      accentLevel: level,
                      index: controller.currentIndex.value,
                      total: total,
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
    required this.word,
    required this.level,
    required this.progress,
    required this.total,
  });

  final PracticeSessionController controller;
  final Word? word;
  final int level;
  final double progress;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = HskPalette.accentForLevel(level, theme.colorScheme);
    final exercise = controller.currentExercise.value;
    final stageLabel = _labelForType(exercise?.type);
    final title = word?.word ?? 'Luyện gõ câu ví dụ';

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
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      stageLabel,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (level > 0)
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
            'Bài ${controller.currentIndex.value + 1}/$total • Đúng ${controller.score.value}',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _labelForType(ExerciseType? type) {
    switch (type) {
      case ExerciseType.typeFromVietnamese:
        return 'Gõ câu từ nghĩa tiếng Việt';
      case ExerciseType.typeFromPinyin:
        return 'Gõ câu từ pinyin';
      case ExerciseType.typeMissingWord:
        return 'Điền từ bị ẩn trong câu';
      case ExerciseType.typeFullSentenceCopy:
        return 'Chép lại câu tiếng Trung';
      case ExerciseType.typeTransformed:
        return 'Viết câu biến đổi/AI';
      default:
        return 'Luyện gõ câu ví dụ';
    }
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.controller});

  final PracticeSessionController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = controller.totalExercises;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.background,
            theme.colorScheme.surface,
          ],
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
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    blurRadius: 26,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 72,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Hoàn thành luyện gõ câu!',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Điểm số: ${controller.score.value}/$total',
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bạn đã hoàn tất toàn bộ chuỗi luyện gõ câu cho unit này.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: controller.restart,
                    icon: const Icon(Icons.replay),
                    label: const Text('Luyện lại từ đầu'),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    label: const Text('Quay về'),
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
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.background,
            scheme.surface,
          ],
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
                Icon(
                  Icons.self_improvement_outlined,
                  size: 72,
                  color: scheme.secondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa có dữ liệu luyện tập',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Hãy chọn bài học và bổ sung câu ví dụ trước khi luyện.',
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
