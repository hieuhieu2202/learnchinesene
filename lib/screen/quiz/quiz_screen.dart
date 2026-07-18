import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../models/quiz_question.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/quiz_option_button.dart';
import '../review/review_screen.dart';
import 'controller/quiz_controller.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(QuizController());
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              controller.complete.value
                  ? 'Hoàn thành bài học'
                  : 'Luyện tập nhanh',
              style: const TextStyle(fontWeight: FontWeight.w800),
            )),
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.questions.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.quiz_outlined,
            title: 'Chưa đủ từ để kiểm tra',
            message: 'Hoạt động này cần ít nhất bốn đáp án khác nhau.',
          );
        }
        if (controller.complete.value) {
          return _result(context, controller);
        }
        return _question(
            context, controller, controller.questions[controller.index.value]);
      }),
    );
  }

  Widget _question(
          BuildContext context, QuizController controller, QuizQuestion q) =>
      Column(
        children: [
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: ResponsiveHelper.contentMaxWidth(context)),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    ResponsiveHelper.horizontalPadding(context),
                    4,
                    ResponsiveHelper.horizontalPadding(context),
                    20,
                  ),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: (controller.index.value + 1) /
                                controller.questions.length,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${controller.index.value + 1}/${controller.questions.length}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      _label(q.type),
                      style: const TextStyle(
                        color: AppColors.red,
                        fontSize: 12,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      q.question,
                      style: const TextStyle(
                        fontSize: 25,
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (q.type == QuizType.listening) ...[
                      const SizedBox(height: 18),
                      Center(
                        child: InkWell(
                          onTap: () => controller.playAudio(q.audioUrl),
                          borderRadius: BorderRadius.circular(40),
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.red, AppColors.orange],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.volume_up_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 26),
                    ...q.options.asMap().entries.map((e) {
                      final state = controller.selected.value == null
                          ? QuizOptionState.idle
                          : e.value == q.correctAnswer
                              ? QuizOptionState.correct
                              : controller.selected.value == e.value
                                  ? QuizOptionState.wrong
                                  : QuizOptionState.idle;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 11),
                        child: QuizOptionButton(
                          text: e.value,
                          index: e.key,
                          state: state,
                          enabled: controller.selected.value == null,
                          onPressed: () => controller.choose(q, e.value),
                        ),
                      );
                    }),
                    if (controller.selected.value != null)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: controller.selected.value == q.correctAnswer
                              ? const Color(0xFFE7F7F0)
                              : const Color(0xFFFFE9E7),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              controller.selected.value == q.correctAnswer
                                  ? Icons.celebration_rounded
                                  : Icons.lightbulb_rounded,
                              color:
                                  controller.selected.value == q.correctAnswer
                                      ? AppColors.success
                                      : AppColors.error,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                controller.selected.value == q.correctAnswer
                                    ? 'Xuất sắc! Bạn đã trả lời đúng.'
                                    : 'Đáp án đúng là ${q.correctAnswer}.',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (controller.selected.value != null)
            _bottom(
              context,
              PrimaryButton(
                label: controller.index.value + 1 == controller.questions.length
                    ? 'Xem kết quả'
                    : 'Câu tiếp theo',
                onPressed: controller.next,
              ),
            ),
        ],
      );

  Widget _result(BuildContext context, QuizController controller) {
    final percent =
        (controller.score.value / controller.questions.length * 100).round();
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: ResponsiveHelper.contentMaxWidth(context)),
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.horizontalPadding(context),
            vertical: 24,
          ),
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.redDark, AppColors.red, AppColors.orange],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    size: 58,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$percent%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Đúng ${controller.score.value}/${controller.questions.length} câu',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              percent >= 80
                  ? '太棒了! Bạn làm rất tốt.'
                  : 'Cố gắng tốt lắm — luyện tập sẽ giúp bạn tiến bộ.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            const Text(
              'Mỗi câu trả lời đều giúp ghi nhớ tốt hơn. Hãy tiếp tục nhé!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, height: 1.5),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Làm lại',
              icon: Icons.replay_rounded,
              onPressed: controller.load,
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => Get.off(() => const ReviewScreen()),
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text('Ôn lại câu sai'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottom(BuildContext context, Widget child) => Container(
        alignment: Alignment.center,
        padding: EdgeInsets.fromLTRB(
          ResponsiveHelper.horizontalPadding(context),
          12,
          ResponsiveHelper.horizontalPadding(context),
          12 + MediaQuery.paddingOf(context).bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: ResponsiveHelper.contentMaxWidth(context)),
          child: child,
        ),
      );

  String _label(QuizType t) => switch (t) {
        QuizType.listening => 'NGHE HIỂU',
        QuizType.chineseToPinyin => 'PINYIN',
        _ => 'NGHĨA CỦA TỪ',
      };
}
