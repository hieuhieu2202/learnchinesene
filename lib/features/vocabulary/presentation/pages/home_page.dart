import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../../domain/entities/word.dart';
import '../controllers/home_controller.dart';
import '../controllers/practice_session_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hành trình HSK'),
      ),
      body: Obx(() {
        final isLoading = controller.isLoading.value;
        final overview = controller.hskOverview;
        return RefreshIndicator(
          onRefresh: controller.loadDashboard,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              const _WelcomeHeader(),
              const SizedBox(height: 16),
              _ReviewCard(reviewCount: controller.reviewCount.value),
              const SizedBox(height: 24),
              const _QuickActions(),
              const SizedBox(height: 32),
              _LevelSection(
                isLoading: isLoading,
                overview: overview,
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chào mừng trở lại!',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Hoàn thành hành trình HSK bằng cách luyện gõ qua từng cấp độ.',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.reviewCount});

  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
              child: Icon(Icons.task_alt, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ôn tập hôm nay',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reviewCount == 0
                        ? 'Không có từ nào cần ôn. Bạn có thể khám phá bài mới!'
                        : 'Có $reviewCount từ đang chờ bạn củng cố.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            FilledButton(
              onPressed: () => Get.toNamed(AppRoutes.reviewToday),
              child: const Text('Bắt đầu'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Truy cập nhanh',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: const [
            _QuickActionButton(
              icon: Icons.view_list,
              label: 'Danh sách bài học',
              route: AppRoutes.sections,
            ),
            _QuickActionButton(
              icon: Icons.bolt,
              label: 'Hành trình luyện gõ',
              practiceMode: PracticeMode.journey,
            ),
            _QuickActionButton(
              icon: Icons.smart_toy,
              label: 'Hỏi AI',
              route: AppRoutes.aiChat,
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    this.route,
    this.practiceMode,
  });

  final IconData icon;
  final String label;
  final String? route;
  final PracticeMode? practiceMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        if (practiceMode != null) {
          Get.toNamed(AppRoutes.practiceSession, arguments: {
            'mode': practiceMode,
            'words': const <Word>[],
          });
          return;
        }
        if (route != null) {
          if (route == AppRoutes.sections) {
            Get.toNamed(route!, arguments: {'level': 1});
          } else {
            Get.toNamed(route!);
          }
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        width: 160,
        height: 120,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelSection extends StatelessWidget {
  const _LevelSection({
    required this.isLoading,
    required this.overview,
  });

  final bool isLoading;
  final List<HskLevelOverview> overview;

  static const _descriptions = {
    1: 'Phát âm và từ vựng nền tảng',
    2: 'Mở rộng câu giao tiếp thông dụng',
    3: 'Chủ đề đời sống hằng ngày',
    4: 'Tự tin trong môi trường học tập và làm việc',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (isLoading && overview.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn cấp độ HSK',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 900
                ? 4
                : constraints.maxWidth > 600
                    ? 3
                    : 2;
            const spacing = 16.0;
            final availableWidth = constraints.maxWidth - spacing * (crossAxisCount - 1);
            final itemWidth = availableWidth / crossAxisCount;
            final targetHeight = crossAxisCount >= 3 ? 220.0 : 240.0;
            final childAspectRatio = itemWidth / targetHeight;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: overview.isEmpty ? 4 : overview.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: spacing,
                crossAxisSpacing: spacing,
                childAspectRatio: childAspectRatio,
              ),
              itemBuilder: (context, index) {
                final item = overview.isEmpty
                    ? HskLevelOverview(level: index + 1, sectionCount: 0, totalWords: 0, masteredWords: 0)
                    : overview[index];
                return _HskLevelCard(
                  item: item,
                  description: _descriptions[item.level] ?? '',
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _HskLevelCard extends StatelessWidget {
  const _HskLevelCard({
    required this.item,
    required this.description,
  });

  final HskLevelOverview item;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalWords = item.totalWords;
    final masteredWords = item.masteredWords;
    return InkWell(
      onTap: () => Get.toNamed(
        AppRoutes.sections,
        arguments: {'level': item.level},
      ),
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.primaryContainer.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                    child: Text(
                      item.level.toString(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'HSK ${item.level}',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Text(
                  description,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(value: item.progress),
              const SizedBox(height: 8),
              Text(
                '${item.sectionCount} bài • ${masteredWords}/${totalWords == 0 ? 0 : totalWords} từ thuộc',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Khám phá',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
