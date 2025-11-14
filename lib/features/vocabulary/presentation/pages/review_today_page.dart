import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../controllers/review_today_controller.dart';
import '../theme/hsk_palette.dart';
import '../utils/hsk_utils.dart';
import '../utils/navigation_utils.dart';
import '../widgets/word_list_item.dart';

class ReviewTodayPage extends GetView<ReviewTodayController> {
  const ReviewTodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final words = controller.words;
        final gradient = const LinearGradient(
          colors: [Color(0xFFFFF5EC), Color(0xFFEFF9FF), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );

        return Container(
          decoration: BoxDecoration(gradient: gradient),
          child: SafeArea(
            child: Column(
              children: [
                const _ReviewHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ReviewSummary(
                          total: words.length,
                          onStart: words.isEmpty
                              ? null
                              : () => navigateAfterFrame(() {
                                    Get.toNamed(
                                      AppRoutes.practiceSession,
                                      arguments: {
                                        'words': words.toList(),
                                      },
                                    );
                                  }),
                        ),
                        const SizedBox(height: 24),
                        if (words.isEmpty)
                          const _EmptyReviewState()
                        else ...[
                          Text(
                            'Danh sách cần ôn',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 16),
                          ...List.generate(words.length, (index) {
                            final word = words[index];
                            final level = parseHskLevel(
                              sectionId: word.sectionId,
                              sectionTitle: word.sectionTitle,
                            );
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index == words.length - 1 ? 0 : 12,
                              ),
                              child: WordListItem(word: word, level: level),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _ReviewHeader extends StatelessWidget {
  const _ReviewHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Ôn tập hôm nay',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewSummary extends StatelessWidget {
  const _ReviewSummary({required this.total, required this.onStart});

  final int total;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = HskPalette.accentForLevel(1, theme.colorScheme);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [accent.withOpacity(0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            total == 0
                ? 'Không có từ nào cần ôn hôm nay'
                : 'Bạn có $total từ cần ôn',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            total == 0
                ? 'Hãy quay lại các bài học để tiếp tục hành trình.'
                : 'Hoàn thành đủ 10 bước gõ để giữ vững phong độ.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (onStart != null)
            FilledButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_circle),
              label: const Text('Bắt đầu luyện gõ'),
            ),
        ],
      ),
    );
  }
}

class _EmptyReviewState extends StatelessWidget {
  const _EmptyReviewState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Không có từ nào trong danh sách ôn',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tiếp tục học các unit mới để mở khoá thêm nhiệm vụ ôn tập.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
