import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../../domain/entities/word.dart';
import '../controllers/home_controller.dart';
import '../theme/hsk_palette.dart';
import '../utils/navigation_utils.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final index = controller.selectedTab.value;
      final pages = <Widget>[
        _DashboardTab(controller: controller),
        const _AiHubTab(),
        _SystemHubTab(controller: controller),
      ];

      return Scaffold(
        body: IndexedStack(
          index: index,
          children: pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: controller.changeTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.school_outlined),
              selectedIcon: Icon(Icons.school),
              label: 'Học',
            ),
            NavigationDestination(
              icon: Icon(Icons.smart_toy_outlined),
              selectedIcon: Icon(Icons.smart_toy),
              label: 'AI',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Hệ thống',
            ),
          ],
        ),
      );
    });
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final overview = controller.hskOverview.toList();
      final reviewCount = controller.reviewCount.value;

      final quickItems = [
        _NavigationItem(
          icon: Icons.dashboard_customize_outlined,
          title: 'Lộ trình HSK',
          subtitle: 'Khám phá cấp độ và unit theo giáo trình.',
          onTap: () => navigateAfterFrame(
            () => Get.toNamed(AppRoutes.sections, arguments: {'level': 1}),
          ),
        ),
        _NavigationItem(
          icon: Icons.flash_on,
          title: 'Luyện câu nhanh',
          subtitle: 'Bắt đầu 10 vòng gõ với các câu tiêu biểu.',
          onTap: () => navigateAfterFrame(() {
            Get.toNamed(
              AppRoutes.practiceSession,
              arguments: {
                'words': const <Word>[],
              },
            );
          }),
        ),
        _NavigationItem(
          icon: Icons.check_circle_outline,
          title: 'Ôn tập hôm nay',
          subtitle: reviewCount > 0
              ? 'Có $reviewCount từ đang chờ bạn củng cố.'
              : 'Giữ nhịp học đều đặn mỗi ngày.',
          onTap: () => navigateAfterFrame(() => Get.toNamed(AppRoutes.reviewToday)),
        ),
      ];

      return _GradientBackground(
        child: CustomScrollView(
          key: const PageStorageKey('home-dashboard'),
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
                child: _NavigationGroup(
                  title: 'Điều hướng nhanh',
                  subtitle:
                      'Chọn điểm bắt đầu cho phiên học gõ tiếng Trung hôm nay.',
                  items: quickItems,
                ),
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
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      );
    });
  }
}

class _AiHubTab extends StatelessWidget {
  const _AiHubTab();

  @override
  Widget build(BuildContext context) {
    return _GradientBackground(
      child: ListView(
        key: const PageStorageKey('ai-hub'),
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        children: [
          Text(
            'Trung tâm AI trợ giảng',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sử dụng AI để mở rộng ngữ cảnh, giải thích chi tiết và tạo bài luyện gõ cá nhân hóa.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          _AiSection(
            title: 'Hỏi đáp tức thì',
            subtitle: 'Trò chuyện với trợ giảng AI về mọi câu hỏi tiếng Trung.',
            items: [
              _AiSectionItem(
                icon: Icons.smart_toy_outlined,
                title: 'AI trợ giảng',
                subtitle: 'Đặt câu hỏi, xin ví dụ và nhận phản hồi ngay lập tức.',
                onTap: () => navigateAfterFrame(
                  () => Get.toNamed(AppRoutes.aiChat),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _AiInfoCard(
            icon: Icons.menu_book_outlined,
            title: 'Giải thích ví dụ trong HSK',
            message:
                'Vào trang chi tiết từ và chạm vào nút AI trong từng câu ví dụ để nhận giải thích ngữ pháp.',
          ),
          const SizedBox(height: 28),
          _AiSection(
            title: 'Gợi ý luyện câu',
            subtitle: 'Tạo thêm câu ví dụ để luyện 10 bước gõ cho từng từ.',
            items: [
              _AiSectionItem(
                icon: Icons.auto_awesome_outlined,
                title: 'AI gợi ý câu luyện tập',
                subtitle: 'Sinh câu mới có chứa từ bạn cần củng cố.',
                onTap: () => navigateAfterFrame(
                  () => Get.toNamed(
                    AppRoutes.aiChat,
                    arguments: {
                      'context':
                          'Hãy tạo các câu ví dụ mới dễ gõ có chứa từ vựng tôi đang học.',
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AiSection extends StatelessWidget {
  const _AiSection({
    required this.title,
    required this.subtitle,
    required this.items,
  });

  final String title;
  final String subtitle;
  final List<_AiSectionItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 18),
        Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              _AiActionCard(item: items[i]),
              if (i != items.length - 1) const SizedBox(height: 14),
            ],
          ],
        ),
      ],
    );
  }
}

class _AiInfoCard extends StatelessWidget {
  const _AiInfoCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withOpacity(0.12), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AiSectionItem {
  const _AiSectionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.accent,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? accent;
}

class _AiActionCard extends StatelessWidget {
  const _AiActionCard({required this.item});

  final _AiSectionItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = item.accent ?? theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: accent.withOpacity(0.14),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(
                  item.icon,
                  color: accent,
                  size: 28,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SystemHubTab extends StatelessWidget {
  const _SystemHubTab({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final systemItems = [
      _NavigationItem(
        icon: Icons.settings_suggest_outlined,
        title: 'Cài đặt hệ thống',
        subtitle: 'Điều chỉnh TTS, giao diện và nhắc ôn tập.',
        onTap: () => navigateAfterFrame(() => Get.toNamed(AppRoutes.settings)),
      ),
      _NavigationItem(
        icon: Icons.insights_outlined,
        title: 'Hồ sơ & thành tích',
        subtitle: 'Theo dõi số từ đã thuần thục và chuỗi ngày học.',
        onTap: () => navigateAfterFrame(() => Get.toNamed(AppRoutes.profile)),
      ),
      _NavigationItem(
        icon: Icons.check_circle_outline,
        title: 'Ôn tập hôm nay',
        subtitle: 'Vào lại danh sách từ cần củng cố trong ngày.',
        onTap: () => navigateAfterFrame(() => Get.toNamed(AppRoutes.reviewToday)),
      ),
    ];

    final supportItems = [
      _NavigationItem(
        icon: Icons.info_outline,
        title: 'Giới thiệu lộ trình',
        subtitle: 'Xem tổng quan 10 bước gõ cho mỗi từ vựng.',
        onTap: () => controller.changeTab(0),
      ),
    ];

    return _GradientBackground(
      child: ListView(
        key: const PageStorageKey('system-hub'),
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        children: [
          Text(
            'Trung tâm hệ thống',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Quản lý cấu hình học tập, xem thống kê và truy cập nhanh các tiện ích.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          _NavigationGroup(
            title: 'Quản lý ứng dụng',
            subtitle: 'Tùy chỉnh trải nghiệm học và xem tiến trình chi tiết.',
            items: systemItems,
          ),
          const SizedBox(height: 32),
          _NavigationGroup(
            title: 'Hỗ trợ nhanh',
            subtitle: 'Quay lại trang tổng quan để tiếp tục hành trình gõ.',
            items: supportItems,
          ),
        ],
      ),
    );
  }
}

class _GradientBackground extends StatelessWidget {
  const _GradientBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.background,
            scheme.surface,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: child,
      ),
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
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surfaceVariant,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.08),
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

class _NavigationCard extends StatelessWidget {
  const _NavigationCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.background,
    this.accent,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color background;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = accent ?? theme.colorScheme.primary;
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
                color: accentColor.withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, 12),
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
                backgroundColor: accentColor.withOpacity(0.12),
                child: Icon(icon, color: accentColor, size: 26),
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

class _NavigationGroup extends StatelessWidget {
  const _NavigationGroup({
    required this.title,
    required this.subtitle,
    required this.items,
  });

  final String title;
  final String subtitle;
  final List<_NavigationItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            const spacing = 16.0;
            double itemWidth;
            if (maxWidth >= 1080) {
              itemWidth = (maxWidth - spacing * 2) / 3;
            } else if (maxWidth >= 720) {
              itemWidth = (maxWidth - spacing) / 2;
            } else {
              itemWidth = maxWidth;
            }

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final item in items)
                  SizedBox(
                    width: itemWidth,
                    child: _NavigationCard(
                      icon: item.icon,
                      title: item.title,
                      subtitle: item.subtitle,
                      onTap: item.onTap,
                      background: item.background ?? theme.colorScheme.surface,
                      accent: item.accent,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _NavigationItem {
  const _NavigationItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.background,
    this.accent,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? background;
  final Color? accent;
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
