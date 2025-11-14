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
      body: Obx(
        () {
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
          return Column(
            children: [
              LinearProgressIndicator(
                value: (controller.currentIndex.value + 1) /
                    controller.questions.length,
              ),
              Expanded(
                child: PracticeQuestionCard(question: question),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.markWrong,
                        child: const Text('Sai'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: controller.markCorrect,
                        child: const Text('Đúng'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
          const SizedBox(height: 16),
          Text(
            'Hoàn thành! Điểm số: ${controller.score}/${controller.questions.length}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              controller.currentIndex.value = 0;
              controller.isFinished.value = false;
              controller.score.value = 0;
            },
            child: const Text('Làm lại'),
          ),
        ],
      ),
    );
  }
}
