import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
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

      return _GradientBackground(
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            key: const PageStorageKey('home-dashboard'),
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                sliver: SliverToBoxAdapter(
                  child: _HomeWelcomeCard(reviewCount: reviewCount),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const _SectionTitle(text: 'Chọn cấp độ HSK'),
                          const Spacer(),
                          TextButton(
                            onPressed: () => navigateAfterFrame(
                              () => Get.toNamed(
                                AppRoutes.sections,
                                arguments: {'level': 1},
                              ),
                            ),
                            child: const Text('Xem tất cả'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _SimpleLevelList(isLoading: isLoading, overview: overview),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _HomeWelcomeCard extends StatelessWidget {
  const _HomeWelcomeCard({required this.reviewCount});

  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final reviewLabel = reviewCount > 0
        ? '$reviewCount từ cần ôn tập hôm nay'
        : 'Không có từ cần ôn tập hôm nay';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Xin chào!',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Lựa chọn cấp độ HSK và luyện câu ví dụ chuẩn.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [
                scheme.surface,
                scheme.surfaceVariant.withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ôn tập hôm nay',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                reviewLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              if (reviewCount > 0) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => navigateAfterFrame(() {
                    Get.toNamed(AppRoutes.reviewToday);
                  }),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Bắt đầu ôn tập'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
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
            subtitle: 'Tạo thêm câu ví dụ để thực hành gõ câu linh hoạt.',
            items: [
              _AiSectionItem(
                icon: Icons.auto_awesome_outlined,
                title: 'AI gợi ý câu luyện tập',
                subtitle: 'Sinh câu mới có chứa từ bạn cần củng cố.',
                onTap: () => navigateAfterFrame(
                  () => Get.toNamed(
                    AppRoutes.aiChat,
                    arguments: {
                      'prompt':
                        'Hãy tạo các câu ví dụ mới dễ gõ có chứa từ vựng tôi đang học. Ưu tiên câu ngắn gọn để luyện gõ nhanh.',
                      'displayText':
                          'Gợi ý giúp mình thêm câu luyện tập nhé!',
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
        title: 'Giới thiệu luyện câu',
        subtitle: 'Xem hướng dẫn luyện câu qua các ví dụ.',
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
            subtitle: 'Quay lại trang tổng quan để tiếp tục luyện câu.',
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _SimpleLevelList extends StatelessWidget {
  const _SimpleLevelList({required this.isLoading, required this.overview});

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
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width - 48;
        final columns = _preferredLevelColumns(maxWidth);
        final spacing = 16.0;
        final itemWidth =
            (maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in items)
              SizedBox(
                width: itemWidth,
                child: _SimpleLevelCard(
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

int _preferredLevelColumns(double maxWidth) {
  if (maxWidth < 420) {
    return 1;
  }
  if (maxWidth < 720) {
    return 2;
  }
  return 3;
}

class _SimpleLevelCard extends StatelessWidget {
  const _SimpleLevelCard({required this.item, this.disabled = false});

  final HskLevelOverview item;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final badge = HskPalette.badgeColor(item.level, scheme);
    final accent = HskPalette.accentForLevel(item.level, scheme);
    final progress = item.progress.clamp(0, 1).toDouble();
    final progressLabel = item.totalWords == 0
        ? 'Chưa có dữ liệu'
        : '${item.masteredWords}/${item.totalWords} từ đã thuộc';

    return Opacity(
      opacity: disabled ? 0.6 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
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
              color: scheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: badge.withOpacity(0.18)),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: badge.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'HSK\n${item.level}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: badge,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.sectionCount} bài học',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: accent.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(accent),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        progressLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
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

