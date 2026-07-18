import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/responsive/responsive_layout.dart';
import '../quiz/quiz_screen.dart';
import '../speaking/speaking_screen.dart';
import '../word_list/word_list_screen.dart';
import 'controller/learning_overview_controller.dart';

class LearningOverviewScreen extends StatelessWidget {
  const LearningOverviewScreen({super.key});

  void _go(Widget screen, int unitId, String title) {
    Get.to(
      () => screen,
      arguments: {'unitId': unitId, 'unitTitle': title},
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LearningOverviewController());

    return Scaffold(
      appBar: AppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final m = controller.metrics;
        final words = m['words'] ?? 0;
        final examples = m['examples'] ?? 0;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: ResponsiveHelper.contentMaxWidth(context)),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                ResponsiveHelper.horizontalPadding(context),
                0,
                ResponsiveHelper.horizontalPadding(context),
                32,
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.redDark, AppColors.red],
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BÀI HỌC TIẾP THEO',
                        style: TextStyle(
                          color: Color(0xCCFFFFFF),
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        controller.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          _metric(Icons.style_rounded, '$words từ'),
                          const SizedBox(width: 18),
                          _metric(
                            Icons.chat_bubble_outline_rounded,
                            '$examples câu mẫu',
                          ),
                          const SizedBox(width: 18),
                          _metric(
                            Icons.schedule_rounded,
                            '${(words * .7).ceil()} phút',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                const Text(
                  'Chọn hoạt động',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                _activity(
                  Icons.style_rounded,
                  'Học từ vựng',
                  'Ghi nhớ từ mới qua thẻ học trực quan',
                  AppColors.red,
                  () => _go(const WordListScreen(), controller.unitId,
                      controller.title),
                ),
                _activity(
                  Icons.quiz_rounded,
                  'Bắt đầu kiểm tra',
                  'Luyện nghĩa, pinyin và nghe hiểu',
                  AppColors.orange,
                  () => _go(
                      const QuizScreen(), controller.unitId, controller.title),
                ),
                _activity(
                  Icons.mic_rounded,
                  'Luyện phát âm',
                  'Nhận phản hồi phát âm ngay lập tức',
                  AppColors.success,
                  () => _go(const SpeakingScreen(), controller.unitId,
                      controller.title),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _metric(IconData i, String t) => Expanded(
        child: Row(
          children: [
            Icon(i, color: Colors.white70, size: 17),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                t,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _activity(
    IconData icon,
    String t,
    String sub,
    Color c,
    VoidCallback tap,
  ) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(21),
          child: InkWell(
            onTap: tap,
            borderRadius: BorderRadius.circular(21),
            child: Padding(
              padding: const EdgeInsets.all(17),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: c.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: c),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sub,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
        ),
      );
}
