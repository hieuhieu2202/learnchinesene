import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/word_card.dart';
import '../quiz/quiz_screen.dart';
import '../word_detail/word_detail_screen.dart';
import 'controller/review_controller.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReviewController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ôn lại từ sai',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final words = controller.words;
        if (words.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.verified_rounded,
            title: 'Bạn đã ôn xong!',
            message: 'Hiện không còn từ khó nào cần ôn lại.',
          );
        }
        return Column(
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: ResponsiveHelper.contentMaxWidth(context)),
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      ResponsiveHelper.horizontalPadding(context),
                      8,
                      ResponsiveHelper.horizontalPadding(context),
                      22,
                    ),
                    children: [
                      _ReviewHero(count: words.length),
                      const SizedBox(height: 20),
                      for (final word in words)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            children: [
                              WordCard(
                                word: word,
                                onTap: () => Get.to(
                                  () => const WordDetailScreen(),
                                  arguments: {'word': word},
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 7, 8, 0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.close_rounded,
                                      size: 15,
                                      color: AppColors.error,
                                    ),
                                    Text(
                                      ' ${word.wrongCount} lần sai',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.error,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${word.correctCount} lần đúng',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ],
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
            Container(
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
                child: PrimaryButton(
                  label: 'Bắt đầu ôn tập',
                  icon: Icons.quiz_rounded,
                  onPressed: () => Get.to(
                    () => const QuizScreen(),
                    arguments: {'unitTitle': 'Ôn tập', 'reviewWords': words},
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _ReviewHero extends StatelessWidget {
  const _ReviewHero({required this.count});
  final int count;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.redDark, AppColors.red],
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            const Icon(Icons.psychology_alt_rounded,
                color: Colors.white, size: 38),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$count từ cần củng cố',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ôn tập có trọng tâm giúp bạn biến lỗi sai thành kiến thức vững chắc.',
                    style: TextStyle(color: Colors.white70, height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
