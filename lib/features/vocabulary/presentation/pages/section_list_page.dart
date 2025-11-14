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

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [gradient.first, gradient.last, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
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
                          'Hành trình HSK $selectedLevel',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LevelSwitcher(controller: controller, selectedLevel: selectedLevel),
                        const SizedBox(height: 20),
                        _LevelHero(
                          selectedLevel: selectedLevel,
                          sectionCount: sectionCount,
                          totalWords: totalWords,
                          masteredWords: masteredWords,
                          progress: progress,
                          firstSection: sections.isEmpty ? null : sections.first,
                        ),
                        const SizedBox(height: 24),
                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (sections.isEmpty)
                          const _EmptyState()
                        else ...[
                          Text(
                            'Danh sách bài học',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 16),
                          for (var index = 0; index < sections.length; index++)
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: index == sections.length - 1 ? 0 : 16,
                              ),
                              child: _UnitCard(
                                progress: sections[index],
                                level: selectedLevel,
                              ),
                            ),
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
          backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        );
      }),
    );
  }
}

class _LevelHero extends StatelessWidget {
  const _LevelHero({
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
    final accent = HskPalette.accentForLevel(selectedLevel, theme.colorScheme);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [accent.withOpacity(0.15), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.08),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng quan HSK $selectedLevel',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress.clamp(0, 1).toDouble(),
            minHeight: 8,
            backgroundColor: accent.withOpacity(0.15),
            color: accent,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$sectionCount bài học',
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${masteredWords}/${totalWords == 0 ? 0 : totalWords} từ đã thuộc',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (firstSection != null)
                FilledButton.tonal(
                  onPressed: () {
                    if (firstSection == null) return;
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
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Bắt đầu học'),
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
        onTap: () => navigateAfterFrame(() {
          Get.toNamed(
            AppRoutes.wordList,
            arguments: {
              'sectionId': progress.sectionId,
              'sectionTitle': progress.sectionTitle,
            },
          );
        }),
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
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
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      progress.unitLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                    ),
                  ),
                  const Spacer(),
                  ProgressChip(progress: progress.progress),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                progress.displayName,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                '${progress.totalWords} từ • ${progress.masteredWords} đã thuộc',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.arrow_forward_rounded, color: accent),
              ),
            ],
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
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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
    );
  }
}
