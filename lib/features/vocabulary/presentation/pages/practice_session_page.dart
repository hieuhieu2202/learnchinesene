import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/practice_session_controller.dart';
import '../widgets/practice_question_card.dart';

class PracticeSessionPage extends GetView<PracticeSessionController> {
  const PracticeSessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Luyện tập'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.questions.isEmpty) {
          return const Center(child: Text('Chưa có dữ liệu luyện tập.'));
        }

        if (controller.isFinished.value) {
          return _buildResult(context);
        }

        final question = controller.currentQuestion;
        if (question == null) {
          return const SizedBox.shrink();
        }

        final progress =
            (controller.currentIndex.value + 1) / controller.questions.length;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 8),
                  Text(
                    'Câu ${controller.currentIndex.value + 1}/${controller.questions.length} • Điểm: ${controller.score.value}',
                  ),
                ],
              ),
            ),
            Expanded(
              child: PracticeQuestionCard(question: question),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildResult(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              'Hoàn thành! Điểm số: ${controller.score}/${controller.questions.length}',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: controller.restart,
              child: const Text('Làm lại'),
            ),
          ],
        ),
      ),
    );
  }
}
