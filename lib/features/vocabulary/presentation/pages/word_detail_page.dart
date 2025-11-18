import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../../domain/entities/word.dart';
import '../controllers/word_detail_controller.dart';
import '../theme/hsk_palette.dart';
import '../utils/hsk_utils.dart';
import '../utils/navigation_utils.dart';

class WordDetailPage extends GetView<WordDetailController> {
  const WordDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final word = controller.word.value;
        if (word == null) {
          return const Center(child: Text('Không tìm thấy từ.'));
        }

        final level = parseHskLevel(
          sectionId: word.sectionId,
          sectionTitle: word.sectionTitle,
        );
        final gradient = HskPalette.gradientForLevel(level);
        final scheme = Theme.of(context).colorScheme;

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
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _Header(title: word.sectionTitle)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _WordHero(word: word, level: level, controller: controller),
                      const SizedBox(height: 24),
                      _PrimaryActions(word: word, controller: controller, level: level),
                      const SizedBox(height: 24),
                      _ExamplesSection(controller: controller, level: level),
                    ]),
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

class _WordHero extends StatelessWidget {
  const _WordHero({required this.word, required this.level, required this.controller});

  final Word word;
  final int level;
  final WordDetailController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = HskPalette.accentForLevel(level, theme.colorScheme);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surfaceVariant,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 120,
            height: 120,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.background.withOpacity(0.8),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Text(
              word.word,
              style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        word.transliteration,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Obx(
                      () => IconButton(
                        icon: Icon(
                          controller.isPlayingAudio.value
                              ? Icons.volume_up_rounded
                              : Icons.volume_down_rounded,
                        ),
                        tooltip: 'Phát âm thanh',
                        onPressed: controller.isPlayingAudio.value
                            ? null
                            : () => controller.playPronunciation(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  word.translation,
                  style: theme.textTheme.titleMedium,
                ),
                if (word.groupSubtitle.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    word.groupSubtitle,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'HSK $level • ${word.mastered ? 'Đã thuộc' : 'Đang học'}',
                    style: theme.textTheme.labelMedium?.copyWith(color: accent),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActions extends StatelessWidget {
  const _PrimaryActions({required this.word, required this.controller, required this.level});

  final Word word;
  final WordDetailController controller;
  final int level;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = HskPalette.accentForLevel(level, theme.colorScheme);
    final basePrompt =
        'Tôi đang học từ "${word.word}" (${word.transliteration}) nghĩa là "${word.translation}". Hãy giải thích thêm cách sử dụng, đưa ví dụ tiếng Trung kèm pinyin và gợi ý luyện tập phù hợp.';
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lựa chọn nhanh',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => navigateAfterFrame(() {
                    Get.toNamed(AppRoutes.practiceSession, arguments: {
                      'words': [word],
                    });
                  }),
                  icon: const Icon(Icons.route),
                  label: const Text('Luyện gõ câu ví dụ'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => navigateAfterFrame(() {
                    Get.toNamed(AppRoutes.aiChat, arguments: {
                      'prompt': basePrompt,
                      'displayText': 'Cho mình thêm gợi ý về từ ${word.word} nhé!',
                      'wordContext': word.word,
                    });
                  }),
                  icon: const Icon(Icons.smart_toy_outlined),
                  label: const Text('Hỏi AI'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExamplesSection extends StatelessWidget {
  const _ExamplesSection({required this.controller, required this.level});

  final WordDetailController controller;
  final int level;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = HskPalette.accentForLevel(level, theme.colorScheme);
    return Obx(() {
      final examples = controller.examples;
      final focusWord = controller.word.value;
      if (examples.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            'Chưa có câu ví dụ cho từ này.',
            style: theme.textTheme.bodyMedium,
          ),
        );
      }

      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Câu ví dụ',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...examples.map(
              (example) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        example.sentenceCn,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        example.sentencePinyin,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        example.sentenceVi,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: accent,
                          ),
                          onPressed: () => navigateAfterFrame(
                            () => Get.toNamed(
                              AppRoutes.aiChat,
                              arguments: {
                                'prompt': _buildGrammarPrompt(
                                  focusWord?.word ?? '',
                                  example.sentenceCn,
                                  example.sentenceVi,
                                ),
                                'displayText':
                                    'Giải thích ngữ pháp câu "${example.sentenceCn}" giúp mình nhé!',
                                'wordContext': focusWord?.word ?? '',
                              },
                            ),
                          ),
                          icon: const Icon(Icons.auto_fix_high_outlined),
                          label: const Text('Giải thích ngữ pháp với AI'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  String _buildGrammarPrompt(String word, String sentenceCn, String translation) {
    final buffer = StringBuffer(
        'Giải thích chi tiết cấu trúc ngữ pháp của câu "$sentenceCn" (nghĩa: $translation). ')
      ..write('Trình bày bằng tiếng Việt, phân tích từng thành phần trong câu');
    if (word.trim().isNotEmpty) {
      buffer.write(' và nhấn mạnh cách sử dụng của từ "$word".');
    } else {
      buffer.write('.');
    }
    buffer.write(' Đề xuất thêm một câu ví dụ tương tự để luyện gõ.');
    return buffer.toString();
  }
}
