import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../../domain/entities/word.dart';
import '../controllers/practice_session_controller.dart';
import '../controllers/word_detail_controller.dart';

class WordDetailPage extends GetView<WordDetailController> {
  const WordDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết từ vựng'),
      ),
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final word = controller.word.value;
          if (word == null) {
            return const Center(child: Text('Không tìm thấy từ.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _WordHero(controller: controller, word: word),
              const SizedBox(height: 20),
              _PrimaryActions(word: word, controller: controller),
              const SizedBox(height: 24),
              _PracticeOptions(word: word),
              const SizedBox(height: 24),
              _ExamplesSection(controller: controller),
            ],
          );
        },
      ),
    );
  }
}

class _WordHero extends StatelessWidget {
  const _WordHero({required this.controller, required this.word});

  final WordDetailController controller;
  final Word word;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 96,
              height: 96,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                word.word,
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          word.transliteration,
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      Obx(
                        () => IconButton(
                          icon: Icon(
                            controller.isPlayingAudio.value ? Icons.volume_up : Icons.volume_down,
                          ),
                          tooltip: 'Phát âm thanh',
                          onPressed: controller.isPlayingAudio.value
                              ? null
                              : () {
                                  controller.playPronunciation();
                                },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    word.translation,
                    style: theme.textTheme.titleMedium,
                  ),
                  if (word.groupSubtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      word.groupSubtitle,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryActions extends StatelessWidget {
  const _PrimaryActions({required this.word, required this.controller});

  final Word word;
  final WordDetailController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contextText = '${word.word} (${word.transliteration}) - ${word.translation}';
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.practiceSession, arguments: {
              'mode': PracticeMode.journey,
              'words': [word],
            }),
            icon: const Icon(Icons.route),
            label: const Text('Luyện 5 cấp độ'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.aiChat, arguments: {
              'context': contextText,
            }),
            icon: const Icon(Icons.smart_toy),
            label: const Text('Hỏi AI'),
          ),
        ),
      ],
    );
  }
}

class _PracticeOptions extends StatelessWidget {
  const _PracticeOptions({required this.word});

  final Word word;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = <_PracticeItem>[
      _PracticeItem(
        title: 'Level 1 · Gõ nghĩa',
        description: 'Nhìn chữ Hán và gõ nghĩa tiếng Việt/Anh.',
        icon: Icons.translate,
        mode: PracticeMode.typingMeaning,
      ),
      _PracticeItem(
        title: 'Level 2 · Gõ pinyin',
        description: 'Ghi nhớ cách đọc bằng cách gõ chuẩn pinyin.',
        icon: Icons.keyboard_alt,
        mode: PracticeMode.typingPinyin,
      ),
      _PracticeItem(
        title: 'Level 3 · Gõ chữ Hán',
        description: 'Dùng bàn phím tiếng Trung để gõ lại chữ.',
        icon: Icons.draw,
        mode: PracticeMode.typingHanzi,
      ),
      _PracticeItem(
        title: 'Level 4 · Điền vào câu',
        description: 'Bổ sung từ còn thiếu dựa trên câu ví dụ.',
        icon: Icons.menu_book,
        mode: PracticeMode.typingFillBlank,
      ),
      _PracticeItem(
        title: 'Level 5 · Gõ cả câu',
        description: 'Chép lại câu ví dụ hoàn chỉnh để ghi nhớ sâu.',
        icon: Icons.edit_note,
        mode: PracticeMode.typingSentence,
      ),
      const _PracticeItem(
        title: 'Nghe & gõ lại (Coming soon)',
        description: 'Nghe audio rồi nhập lại câu hoàn chỉnh.',
        icon: Icons.hearing,
      ),
      const _PracticeItem(
        title: 'Đọc hiểu ví dụ (Coming soon)',
        description: 'Đọc thêm ví dụ mở rộng cho từ này.',
        icon: Icons.chrome_reader_mode,
      ),
      const _PracticeItem(
        title: 'Luyện nét chữ (Coming soon)',
        description: 'Vẽ lại thứ tự nét bằng canvas tương tác.',
        icon: Icons.gesture,
      ),
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn chế độ luyện tập',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...options.map(
              (option) => _PracticeTile(word: word, item: option),
            ),
          ],
        ),
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
  const _PracticeTile({required this.word, required this.item});

  final Word word;
  final _PracticeItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = item.mode != null;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
        child: Icon(item.icon, color: theme.colorScheme.primary),
      ),
      title: Text(item.title),
      subtitle: Text(item.description),
      trailing: enabled ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
      enabled: enabled,
      onTap: enabled
          ? () => Get.toNamed(AppRoutes.practiceSession, arguments: {
                'mode': item.mode,
                'words': [word],
              })
          : null,
    );
  }
}

class _ExamplesSection extends StatelessWidget {
  const _ExamplesSection({required this.controller});

  final WordDetailController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final examples = controller.examples;
      if (examples.isEmpty) {
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Chưa có câu ví dụ cho từ này.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Câu ví dụ',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...examples.map(
            (example) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
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
                      const SizedBox(height: 4),
                      Text(
                        example.sentenceVi,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
