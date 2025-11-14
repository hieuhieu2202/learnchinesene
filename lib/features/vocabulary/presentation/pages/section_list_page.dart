import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../controllers/section_list_controller.dart';
import '../theme/hsk_palette.dart';
import '../widgets/progress_chip.dart';
import '../utils/hsk_utils.dart';
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded),
                              onPressed: () => Navigator.of(context).maybePop(),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
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
                                    'Chọn một unit để bắt đầu luyện tập',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _LevelSwitcher(
                          controller: controller,
                          selectedLevel: selectedLevel,
                        ),
                        const SizedBox(height: 20),
                        _LevelSummaryCard(
                          selectedLevel: selectedLevel,
                          sectionCount: sectionCount,
                          totalWords: totalWords,
                          masteredWords: masteredWords,
                          progress: progress,
                          firstSection: sections.isEmpty ? null : sections.first,
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

class _LevelSwitcher extends StatelessWidget {
  const _LevelSwitcher({required this.controller, required this.selectedLevel});

  final SectionListController controller;
  final int selectedLevel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(4, (index) {
        final level = index + 1;
        final isSelected = selectedLevel == level;
        final badgeColor = HskPalette.badgeColor(level, theme.colorScheme);
        return ChoiceChip(
          label: Text('HSK $level'),
          selected: isSelected,
          onSelected: (_) => controller.changeLevel(level),
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected ? theme.colorScheme.onPrimary : null,
            fontWeight: FontWeight.w600,
          ),
          selectedColor: badgeColor,
          backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.35),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
    required this.firstSection,
  });

  final int selectedLevel;
  final int sectionCount;
  final int totalWords;
  final int masteredWords;
  final double progress;
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
            accent.withOpacity(0.18),
            Colors.white.withOpacity(0.92),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.18),
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
              backgroundColor: accent.withOpacity(0.18),
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
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.12),
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () => navigateAfterFrame(() {
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
              colors: [
                accent.withOpacity(0.16),
                theme.colorScheme.surface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.14),
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
                        color: Colors.white.withOpacity(0.75),
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
                    Icon(Icons.auto_graph_rounded, color: accent, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${(progress.progress * 100).toStringAsFixed(0)}% hoàn thành',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_rounded, color: accent),
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
              color: theme.colorScheme.shadow.withOpacity(0.08),
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
