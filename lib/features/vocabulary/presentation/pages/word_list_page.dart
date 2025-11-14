import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../controllers/practice_session_controller.dart';
import '../controllers/word_list_controller.dart';
import '../theme/hsk_palette.dart';
import '../utils/hsk_utils.dart';
import '../utils/navigation_utils.dart';
import '../widgets/word_list_item.dart';

class WordListPage extends GetView<WordListController> {
  const WordListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final level = parseHskLevel(
      sectionId: controller.sectionId,
      sectionTitle: controller.sectionTitle,
    );
    final gradient = HskPalette.gradientForLevel(level);

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final words = controller.words;
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
                _Header(title: controller.sectionTitle),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _UnitSummary(
                          controller: controller,
                          level: level,
                          onPractice: words.isEmpty
                              ? null
                              : () => navigateAfterFrame(() {
                                    Get.toNamed(
                                      AppRoutes.practiceSession,
                                      arguments: {
                                        'words': words.toList(),
                                        'mode': PracticeMode.journey,
                                      },
                                    );
                                  }),
                        ),
                        const SizedBox(height: 24),
                        if (words.isEmpty)
                          const _EmptyWordState()
                        else ...[
                          Text(
                            'Từ vựng trong unit',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 16),
                          ...List.generate(words.length, (index) {
                            final word = words[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index == words.length - 1 ? 0 : 12,
                              ),
                              child: WordListItem(
                                word: word,
                                level: level,
                                onTap: () => navigateAfterFrame(() {
                                  Get.toNamed(
                                    AppRoutes.wordDetail,
                                    arguments: {'wordId': word.id},
                                  );
                                }),
                              ),
                            );
                          }),
                        ],
                      ],
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

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitSummary extends StatelessWidget {
  const _UnitSummary({
    required this.controller,
    required this.level,
    required this.onPractice,
  });

  final WordListController controller;
  final int level;
  final VoidCallback? onPractice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = HskPalette.accentForLevel(level, theme.colorScheme);
    final totalWords = controller.totalWords;
    final mastered = controller.masteredCount;
    final progress = totalWords == 0 ? 0.0 : mastered / totalWords;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [accent.withOpacity(0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 380;
              final title = Text(
                'HSK $level • ${controller.sectionTitle}',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              );
              final practiceButton = onPractice == null
                  ? null
                  : FilledButton.icon(
                      onPressed: onPractice,
                      icon: const Icon(Icons.play_circle),
                      label: const Text('Luyện hành trình 10 bước'),
                    );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    if (practiceButton != null) ...[
                      const SizedBox(height: 12),
                      practiceButton,
                    ],
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: title),
                  if (practiceButton != null) practiceButton,
                ],
              );
            },
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
            '$totalWords từ vựng • $mastered đã thuộc',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _EmptyWordState extends StatelessWidget {
  const _EmptyWordState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Chưa có từ vựng cho unit này',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Vui lòng thử lại sau khi dữ liệu được cập nhật.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
