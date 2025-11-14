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
        actions: [
          IconButton(
            icon: const Icon(Icons.smart_toy),
            onPressed: () {
              final word = controller.word.value;
              final contextText = word == null
                  ? null
                  : '${word.word} (${word.transliteration}) - ${word.translation}';
              Get.toNamed(AppRoutes.aiChat, arguments: {'context': contextText});
            },
          ),
        ],
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
          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                _WordHeader(word: word),
                const TabBar(
                  tabs: [
                    Tab(text: 'Ví dụ'),
                    Tab(text: 'Luyện nhanh'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _ExamplesTab(controller: controller),
                      _PracticeTab(word: word),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WordHeader extends StatelessWidget {
  const _WordHeader({required this.word});

  final Word word;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            word.word,
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(word.transliteration, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(word.translation, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}

class _ExamplesTab extends StatelessWidget {
  const _ExamplesTab({required this.controller});

  final WordDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: controller.examples.length,
        itemBuilder: (context, index) {
          final example = controller.examples[index];
          return ListTile(
            title: Text(example.sentenceCn),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(example.sentencePinyin),
                const SizedBox(height: 4),
                Text(example.sentenceVi),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) => const Divider(),
      ),
    );
  }
}

class _PracticeTab extends StatelessWidget {
  const _PracticeTab({required this.word});

  final Word word;

  @override
  Widget build(BuildContext context) {
    final modes = {
      PracticeMode.flashcard: 'Flashcard',
      PracticeMode.flashcardReverse: 'Flashcard ngược',
      PracticeMode.pinyin: 'Pinyin',
      PracticeMode.listening: 'Nghe',
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final entry in modes.entries)
          ListTile(
            leading: const Icon(Icons.play_circle),
            title: Text(entry.value),
            onTap: () => Get.toNamed(AppRoutes.practiceSession, arguments: {
              'mode': entry.key,
              'words': [word],
            }),
          ),
      ],
    );
  }
}
