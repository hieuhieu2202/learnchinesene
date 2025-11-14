import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../../domain/entities/word.dart';
import '../controllers/practice_session_controller.dart';
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

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [gradient.first, gradient.last, Colors.white],
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
                      _PracticeTimeline(word: word, level: level),
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
          colors: [accent.withOpacity(0.12), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.08),
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
              color: accent.withOpacity(0.18),
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
    final contextText = '${word.word} (${word.transliteration}) - ${word.translation}';
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
                      'mode': PracticeMode.journey,
                      'words': [word],
                    });
                  }),
                  icon: const Icon(Icons.route),
                  label: const Text('Luyện hành trình 5 cấp'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => navigateAfterFrame(() {
                    Get.toNamed(AppRoutes.aiChat, arguments: {
                      'context': contextText,
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

class _PracticeTimeline extends StatelessWidget {
  const _PracticeTimeline({required this.word, required this.level});

  final Word word;
  final int level;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = HskPalette.accentForLevel(level, theme.colorScheme);
    final options = <_PracticeItem>[
      _PracticeItem(
        title: 'Level 1 · Gõ nghĩa',
        description: 'Nhìn chữ Hán và gõ nghĩa tiếng Việt/Anh.',
        icon: Icons.translate,
        mode: PracticeMode.typingMeaning,
      ),
      _PracticeItem(
        title: 'Level 2 · Gõ Pinyin',
        description: 'Ghi nhớ cách đọc bằng cách gõ chuẩn pinyin.',
        icon: Icons.keyboard_alt_outlined,
        mode: PracticeMode.typingPinyin,
      ),
      _PracticeItem(
        title: 'Level 3 · Gõ chữ Hán',
        description: 'Dùng bàn phím tiếng Trung để gõ lại chữ.',
        icon: Icons.edit_square,
        mode: PracticeMode.typingHanzi,
      ),
      _PracticeItem(
        title: 'Level 4 · Điền vào câu',
        description: 'Bổ sung từ còn thiếu dựa trên câu ví dụ.',
        icon: Icons.menu_book_outlined,
        mode: PracticeMode.typingFillBlank,
      ),
      _PracticeItem(
        title: 'Level 5 · Gõ cả câu',
        description: 'Chép lại câu ví dụ hoàn chỉnh để ghi nhớ sâu.',
        icon: Icons.edit_note,
        mode: PracticeMode.typingSentence,
      ),
      const _PracticeItem(
        title: 'Nghe & gõ lại (Soon)',
        description: 'Nghe audio rồi nhập lại câu hoàn chỉnh.',
        icon: Icons.hearing,
      ),
      const _PracticeItem(
        title: 'Đọc mở rộng (Soon)',
        description: 'Đọc thêm ví dụ mở rộng cho từ này.',
        icon: Icons.chrome_reader_mode,
      ),
      const _PracticeItem(
        title: 'Luyện nét chữ (Soon)',
        description: 'Theo dõi thứ tự nét và tập viết lại.',
        icon: Icons.gesture,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lộ trình luyện gõ',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...options.map((item) => _PracticeTile(word: word, item: item, accent: accent)),
        ],
      ),
    );
  }
}

class _PracticeItem {
  const _PracticeItem({
    required this.title,
    required this.description,
    required this.icon,
    this.mode,
  });

  final String title;
  final String description;
  final IconData icon;
  final PracticeMode? mode;
}

class _PracticeTile extends StatelessWidget {
  const _PracticeTile({required this.word, required this.item, required this.accent});

  final Word word;
  final _PracticeItem item;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = item.mode != null;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      leading: CircleAvatar(
        backgroundColor: accent.withOpacity(0.14),
        child: Icon(item.icon, color: accent),
      ),
      title: Text(item.title),
      subtitle: Text(item.description),
      trailing: enabled ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
      enabled: enabled,
      onTap: enabled
          ? () => navigateAfterFrame(() {
                Get.toNamed(AppRoutes.practiceSession, arguments: {
                  'mode': item.mode,
                  'words': [word],
                });
              })
          : null,
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
}
