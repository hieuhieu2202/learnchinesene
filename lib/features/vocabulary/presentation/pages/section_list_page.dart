import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../controllers/section_list_controller.dart';
import '../theme/hsk_palette.dart';
import '../widgets/progress_chip.dart';
import '../utils/navigation_utils.dart';

class SectionListPage extends GetView<SectionListController> {
  const SectionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final isLoading = controller.isLoading.value;
        final sections = controller.sections.toList();
        final selectedLevel = controller.selectedLevel.value;
        final sectionCount = sections.length;
        final totalWords = controller.totalWords;
        final masteredWords = controller.masteredWords;
        final progress = controller.progress;
        final gradient = HskPalette.gradientForLevel(selectedLevel);
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final backgroundGradient = LinearGradient(
          colors: [
            gradient.first,
            Color.lerp(gradient.last, colorScheme.background, 0.35)!,
            colorScheme.background,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );

        return DecoratedBox(
          decoration: BoxDecoration(gradient: backgroundGradient),
          child: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded),
                              onPressed: () => Navigator.of(context).maybePop(),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'HSK $selectedLevel',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Danh sách unit trong cấp độ này',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Count sections that are fully completed (100%)
                        _LevelSummaryCard(
                          selectedLevel: selectedLevel,
                          sectionCount: sectionCount,
                          totalWords: totalWords,
                          masteredWords: masteredWords,
                          progress: progress,
                          completedSections: sections.where((s) => s.progress >= 1.0).length,
                          firstSection: sections.isEmpty ? null : sections.first,
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isLoading && sections.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: Row(
                        children: [
                          Icon(Icons.menu_book_rounded, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Chọn unit để học',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (sections.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final progress = sections[index];
                          final bottomPadding = index == sections.length - 1 ? 0.0 : 16.0;
                          return Padding(
                            padding: EdgeInsets.only(bottom: bottomPadding),
                            child: _UnitCard(
                              progress: progress,
                              level: selectedLevel,
                            ),
                          );
                        },
                        childCount: sections.length,
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

class _LevelSummaryCard extends StatelessWidget {
  const _LevelSummaryCard({
    required this.selectedLevel,
    required this.sectionCount,
    required this.totalWords,
    required this.masteredWords,
    required this.progress,
    required this.completedSections,
    required this.firstSection,
  });

  final int selectedLevel;
  final int sectionCount;
  final int totalWords;
  final int masteredWords;
  final double progress;
  final int completedSections;
  final SectionProgress? firstSection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = HskPalette.accentForLevel(selectedLevel, colorScheme);
    final progressValue = progress.clamp(0, 1).toDouble();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            colorScheme.surface,
            colorScheme.surfaceVariant,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withAlpha(41),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng quan HSK $selectedLevel',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 8,
              backgroundColor: accent.withAlpha(46),
              color: accent,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _SummaryStat(
                icon: Icons.layers_rounded,
                label: 'Bài học',
                value: '$sectionCount',
                accent: accent,
              ),
              _SummaryStat(
                icon: Icons.book_rounded,
                label: 'Tổng số từ',
                value: '$totalWords',
                accent: accent,
              ),
              _SummaryStat(
                icon: Icons.emoji_events_outlined,
                label: 'Hoàn thành',
                value: '$completedSections',
                accent: accent,
              ),
              _SummaryStat(
                icon: Icons.check_circle_rounded,
                label: 'Đã thuộc',
                value: '$masteredWords',
                accent: accent,
              ),
              _SummaryStat(
                icon: Icons.percent_rounded,
                label: 'Tiến độ',
                value: '${(progressValue * 100).toStringAsFixed(0)}%',
                accent: accent,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: firstSection == null
                  ? null
                  : () {
                      navigateAfterFrame(() {
                        Get.toNamed(
                          AppRoutes.wordList,
                          arguments: {
                            'sectionId': firstSection!.sectionId,
                            'sectionTitle': firstSection!.sectionTitle,
                          },
                        );
                      });
                    },
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Bắt đầu học ngay'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(217),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: accent.withAlpha(31),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accent, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  const _UnitCard({required this.progress, required this.level});

  final SectionProgress progress;
  final int level;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = HskPalette.accentForLevel(level, theme.colorScheme);
    final isLocked = progress.isLocked;
    final bgColors = isLocked
        ? [theme.colorScheme.surfaceVariant, theme.colorScheme.surface]
        : [theme.colorScheme.surface, theme.colorScheme.surfaceVariant];
    final statusColor = isLocked
        ? theme.colorScheme.error.withAlpha(204)
        : accent;
    final statusText = isLocked
        ? 'Hoàn thành unit trước để mở khóa'
        : '${(progress.progress * 100).toStringAsFixed(0)}% hoàn thành';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: isLocked
            ? null
            : () => navigateAfterFrame(() {
                  Get.toNamed(
                    AppRoutes.wordList,
                    arguments: {
                      'sectionId': progress.sectionId,
                      'sectionTitle': progress.sectionTitle,
                    },
                  );
                }),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              colors: bgColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withAlpha(31),
                blurRadius: 28,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.background.withAlpha(204),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        progress.unitLabel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: accent,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (isLocked)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withAlpha(204),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: statusColor, width: 1.2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_rounded, color: statusColor, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Đã khóa',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ProgressChip(
                        progress: progress.progress,
                        color: accent,
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  progress.displayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${progress.totalWords} từ • ${progress.masteredWords} đã thuộc',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(
                      isLocked ? Icons.lock_clock_rounded : Icons.auto_graph_rounded,
                      color: statusColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      statusText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      isLocked ? Icons.remove_red_eye_outlined : Icons.arrow_forward_rounded,
                      color: statusColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withAlpha(20),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chưa có bài học trong cấp độ này',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy quay lại sau khi cập nhật thêm nội dung học tập.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
