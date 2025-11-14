import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../controllers/practice_session_controller.dart';
import '../controllers/word_list_controller.dart';
import '../widgets/word_list_item.dart';

class WordListPage extends GetView<WordListController> {
  const WordListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.sectionTitle),
      ),
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final words = controller.words;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: words.length + 1,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _UnitSummary(controller: controller);
              }
              final word = words[index - 1];
              return WordListItem(
                word: word,
                onTap: () => Get.toNamed(AppRoutes.wordDetail, arguments: {
                  'wordId': word.id,
                }),
              );
            },
          );
        },
      ),
      floatingActionButton: Obx(
        () => controller.words.isEmpty
            ? const SizedBox.shrink()
            : FloatingActionButton.extended(
                onPressed: () => Get.toNamed(AppRoutes.practiceSession, arguments: {
                  'words': controller.words.toList(),
                  'mode': PracticeMode.journey,
                }),
                icon: const Icon(Icons.play_circle),
                label: const Text('Luyện tập'),
              ),
      ),
    );
  }
}

class _UnitSummary extends StatelessWidget {
  const _UnitSummary({required this.controller});

  final WordListController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalWords = controller.totalWords;
    final mastered = controller.masteredCount;
    final progress = totalWords == 0 ? 0.0 : mastered / totalWords;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.sectionTitle,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$totalWords từ vựng',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Text(
                  '$mastered/$totalWords đã thuộc',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
