import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../../domain/entities/word.dart';
import '../controllers/home_controller.dart';
import '../controllers/practice_session_controller.dart';
import '../theme/hsk_palette.dart';
import '../utils/navigation_utils.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final isLoading = controller.isLoading.value;
        final overview = controller.hskOverview.toList();
        final reviewCount = controller.reviewCount.value;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFF5F7), Color(0xFFF5FBFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  sliver: SliverToBoxAdapter(
                    child: _HomeIntro(reviewCount: reviewCount),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: _QuickLaunchRow(),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Chọn cấp độ HSK',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: _LevelGrid(
                      isLoading: isLoading,
                      overview: overview,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _HomeIntro extends StatelessWidget {
  const _HomeIntro({required this.reviewCount});

  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hành trình luyện gõ tiếng Trung',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Hoàn thành 10 bước gõ để thuộc lòng từng từ vựng trong giáo trình HSK.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        _ReviewCard(reviewCount: reviewCount),
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
    final hasReview = reviewCount > 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFFDE7EF), Color(0xFFEFF6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              hasReview ? Icons.checklist : Icons.auto_awesome,
              color: theme.colorScheme.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasReview ? 'Sẵn sàng ôn tập' : 'Không có bài ôn',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  hasReview
                      ? 'Có $reviewCount từ đang chờ bạn củng cố hôm nay.'
                      : 'Bạn có thể tiếp tục hành trình ở các bài học mới.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          FilledButton(
            onPressed: hasReview
                ? () => navigateAfterFrame(() => Get.toNamed(AppRoutes.reviewToday))
                : () => navigateAfterFrame(
                      () => Get.toNamed(AppRoutes.sections, arguments: {'level': 1}),
                    ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(hasReview ? 'Ôn ngay' : 'Học bài'),
          ),
        ],
      ),
    );
  }
}

class _QuickLaunchRow extends StatelessWidget {
  const _QuickLaunchRow();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final spacing = 16.0;
        double itemWidth;
        if (maxWidth >= 900) {
          itemWidth = (maxWidth - spacing * 2) / 3;
        } else if (maxWidth >= 600) {
          itemWidth = (maxWidth - spacing) / 2;
        } else {
          itemWidth = maxWidth;
        }

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: itemWidth,
              child: _QuickActionCard(
                icon: Icons.dashboard_customize_outlined,
                title: 'Lộ trình HSK',
                subtitle: 'Theo dõi từng cấp độ và unit.',
                onTap: () => navigateAfterFrame(
                  () => Get.toNamed(AppRoutes.sections, arguments: {'level': 1}),
                ),
                background: theme.colorScheme.surface,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _QuickActionCard(
                icon: Icons.flash_on,
                title: 'Luyện nhanh',
                subtitle: 'Chạy đủ 5 mode cho các từ đã chọn.',
                onTap: () => navigateAfterFrame(() {
                  Get.toNamed(
                    AppRoutes.practiceSession,
                    arguments: {
                      'mode': PracticeMode.journey,
                      'words': const <Word>[],
                    },
                  );
                }),
                background: theme.colorScheme.surface,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _QuickActionCard(
                icon: Icons.smart_toy_outlined,
                title: 'AI trợ giảng',
                subtitle: 'Nhờ AI tạo thêm ví dụ & giải thích.',
                onTap: () => navigateAfterFrame(() => Get.toNamed(AppRoutes.aiChat)),
                background: theme.colorScheme.surface,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.background,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                child: Icon(icon, color: theme.colorScheme.primary, size: 26),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelGrid extends StatelessWidget {
  const _LevelGrid({required this.isLoading, required this.overview});

  final bool isLoading;
  final List<HskLevelOverview> overview;

  @override
  Widget build(BuildContext context) {
    if (isLoading && overview.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final items = overview.isEmpty
        ? List.generate(
            4,
            (index) => HskLevelOverview(
                  level: index + 1,
                  sectionCount: 0,
                  totalWords: 0,
                  masteredWords: 0,
                ),
          )
        : overview;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1080
            ? 4
            : width >= 840
                ? 3
                : 2;
        const spacing = 16.0;
        final cardWidth = (width - spacing * (crossAxisCount - 1)) / crossAxisCount;
        final cardHeight =
            (cardWidth * 0.72).clamp(220.0, 280.0).toDouble();
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in items)
              SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: _LevelCard(
                  item: item,
                  disabled: overview.isEmpty && isLoading,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.item, this.disabled = false});

  final HskLevelOverview item;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradient = HskPalette.gradientForLevel(item.level);
    final accent = HskPalette.accentForLevel(item.level, theme.colorScheme);
    final badge = HskPalette.badgeColor(item.level, theme.colorScheme);
    final progress = item.progress.clamp(0, 1).toDouble();

    return Opacity(
      opacity: disabled ? 0.6 : 1,
      child: Material(
        color: Colors.transparent,
        child: SizedBox.expand(
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: disabled
                ? null
                : () => navigateAfterFrame(() {
                      Get.toNamed(
                        AppRoutes.sections,
                        arguments: {'level': item.level},
                      );
                    }),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: badge.withOpacity(0.2)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: badge.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'HSK ${item.level}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: badge,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_rounded, color: accent),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  '${item.sectionCount} bài học',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${item.masteredWords}/${item.totalWords == 0 ? 0 : item.totalWords} từ đã thuộc',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: accent.withOpacity(0.15),
                  color: accent,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
