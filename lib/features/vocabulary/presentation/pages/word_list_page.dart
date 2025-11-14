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
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: controller.words.length,
                itemBuilder: (context, index) {
                  final word = controller.words[index];
                  return WordListItem(
                    word: word,
                    onTap: () => Get.toNamed(AppRoutes.wordDetail, arguments: {
                      'wordId': word.id,
                    }),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.practiceSession, arguments: {
          'words': controller.words.toList(),
          'mode': PracticeMode.flashcard,
        }),
        icon: const Icon(Icons.play_circle),
        label: const Text('Luyện tập'),
      ),
    );
  }
}
