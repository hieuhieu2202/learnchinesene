import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/empty_state_widget.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/word_card.dart';
import '../quiz/quiz_screen.dart';
import '../word_detail/word_detail_screen.dart';
import 'controller/word_list_controller.dart';

class WordListScreen extends StatelessWidget {
  const WordListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WordListController());

    return Scaffold(
      appBar: AppBar(
        title: Text(controller.title,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz_rounded),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.hasError.value) {
          return const EmptyStateWidget(
            icon: Icons.error_outline_rounded,
            title: 'Không thể tải bài học',
            message: 'Không thể mở bài từ vựng ngoại tuyến này.',
          );
        }
        final words = controller.words;
        if (words.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.style_outlined,
            title: 'Chưa có từ vựng',
            message: 'Bài học này chưa có dữ liệu từ vựng.',
          );
        }

        final current = words[controller.index.value.clamp(0, words.length - 1)];

        return Column(
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: ResponsiveHelper.contentMaxWidth(context)),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: (controller.index.value + 1) /
                                    words.length,
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${controller.index.value + 1} / ${words.length}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: PageView.builder(
                          controller: controller.pageController,
                          itemCount: words.length,
                          onPageChanged: controller.setIndex,
                          itemBuilder: (context, i) => Padding(
                            padding: const EdgeInsets.fromLTRB(5, 5, 5, 14),
                            child: WordCard(
                              hero: true,
                              word: words[i],
                              onTap: () => Get.to(
                                () => const WordDetailScreen(),
                                arguments: {'word': words[i]},
                              ),
                            ),
                          ),
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
                14,
                ResponsiveHelper.horizontalPadding(context),
                14 + MediaQuery.paddingOf(context).bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 18,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: ResponsiveHelper.contentMaxWidth(context)),
                child: Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: controller.learned.contains(current.id)
                          ? null
                          : () => controller.markLearned(current),
                      icon: Icon(
                        controller.learned.contains(current.id)
                            ? Icons.check_rounded
                            : Icons.bookmark_add_outlined,
                      ),
                      tooltip: 'Đánh dấu đã học',
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        label: controller.index.value == words.length - 1
                            ? 'Kiểm tra bài học'
                            : 'Từ tiếp theo',
                        icon: controller.index.value == words.length - 1
                            ? Icons.quiz_rounded
                            : Icons.arrow_forward_rounded,
                        onPressed: () {
                          if (controller.index.value == words.length - 1) {
                            Get.to(
                              () => const QuizScreen(),
                              arguments: {
                                'unitId': controller.unitId,
                                'unitTitle': controller.title
                              },
                            );
                          } else {
                            controller.next();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
