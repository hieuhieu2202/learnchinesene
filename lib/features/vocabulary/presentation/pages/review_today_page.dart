import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../controllers/practice_session_controller.dart';
import '../controllers/review_today_controller.dart';
import '../widgets/word_list_item.dart';

class ReviewTodayPage extends GetView<ReviewTodayController> {
  const ReviewTodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ôn tập hôm nay'),
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : controller.words.isEmpty
                ? const Center(child: Text('Không có từ nào cần ôn.'))
                : ListView.builder(
                    itemCount: controller.words.length,
                    itemBuilder: (context, index) {
                      final word = controller.words[index];
                      return WordListItem(word: word);
                    },
                  ),
      ),
      floatingActionButton: Obx(
        () => controller.words.isEmpty
            ? const SizedBox.shrink()
            : FloatingActionButton.extended(
                onPressed: () => Get.toNamed(AppRoutes.practiceSession, arguments: {
                  'words': controller.words.toList(),
                  'mode': PracticeMode.flashcard,
                }),
                icon: const Icon(Icons.play_circle),
                label: const Text('Bắt đầu'),
              ),
      ),
    );
  }
}
