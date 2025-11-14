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
        () {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final words = controller.words;
          if (words.isEmpty) {
            return const Center(child: Text('Không có từ nào cần ôn.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: words.length + 1,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _ReviewSummary(total: words.length);
              }
              final word = words[index - 1];
              return WordListItem(word: word);
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
                label: const Text('Bắt đầu'),
              ),
      ),
    );
  }
}

class _ReviewSummary extends StatelessWidget {
  const _ReviewSummary({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bạn có $total từ cần ôn',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Hoàn thành toàn bộ hành trình gõ để củng cố trí nhớ sâu.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
