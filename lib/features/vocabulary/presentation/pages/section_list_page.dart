import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../controllers/section_list_controller.dart';
import '../widgets/progress_chip.dart';

class SectionListPage extends GetView<SectionListController> {
  const SectionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Obx(() {
        final isLoading = controller.isLoading.value;
        final sections = controller.sections.toList();
        final selectedLevel = controller.selectedLevel.value;
        final sectionCount = sections.length;
        final totalWords = controller.totalWords;
        final masteredWords = controller.masteredWords;
        final progress = controller.progress;
        VoidCallback? onStartLearning;
        if (sections.isNotEmpty) {
          final firstSection = sections.first;
          onStartLearning = () {
            Get.toNamed(
              AppRoutes.wordList,
              arguments: {
                'sectionId': firstSection.sectionId,
                'sectionTitle': firstSection.sectionTitle,
              },
            );
          };
        }

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.surfaceVariant.withOpacity(0.25),
                theme.colorScheme.surface,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      Text(
                        'Lộ trình bài học',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Quay lại',
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    children: [
                      _LevelSwitcher(
                        controller: controller,
                        selectedLevel: selectedLevel,
                      ),
                      const SizedBox(height: 20),
                      _LevelHeader(
                        selectedLevel: selectedLevel,
                        sectionCount: sectionCount,
                        totalWords: totalWords,
                        masteredWords: masteredWords,
                        progress: progress,
                        onStartLearning: onStartLearning,
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
                          'Chọn bài học',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...List.generate(sections.length, (index) {
                          final item = sections[index];
                          final bottomSpacing = index == sections.length - 1 ? 0.0 : 16.0;
                          return Padding(
                            padding: EdgeInsets.only(bottom: bottomSpacing),
                            child: _UnitCard(progress: item),
                          );
                        }),
                      ],
                    ],
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
  const _LevelSwitcher({
    required this.controller,
    required this.selectedLevel,
  });

  final SectionListController controller;
  final int selectedLevel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn cấp độ HSK',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(4, (index) {
            final level = index + 1;
            final isSelected = selectedLevel == level;
            return ChoiceChip(
              label: Text('HSK $level'),
              selected: isSelected,
              onSelected: (_) => controller.changeLevel(level),
              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected ? theme.colorScheme.onPrimary : null,
                fontWeight: FontWeight.w600,
              ),
              selectedColor: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            );
          }),
        ),
      ],
    );
  }
}

class _LevelHeader extends StatelessWidget {
  const _LevelHeader({
    required this.selectedLevel,
    required this.sectionCount,
    required this.totalWords,
    required this.masteredWords,
    required this.progress,
    this.onStartLearning,
  });

  final int selectedLevel;
  final int sectionCount;
  final int totalWords;
  final int masteredWords;
  final double progress;
  final VoidCallback? onStartLearning;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HSK $selectedLevel overview',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0).toDouble(),
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
            backgroundColor: theme.colorScheme.onPrimary.withOpacity(0.15),
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
                    const SizedBox(height: 4),
                    Text(
                      '${masteredWords}/${totalWords == 0 ? 0 : totalWords} từ đã thuộc',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              FilledButton.tonal(
                onPressed: onStartLearning,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text('Học ngay'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  const _UnitCard({required this.progress});

  final SectionProgress progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => Get.toNamed(
        AppRoutes.wordList,
        arguments: {
          'sectionId': progress.sectionId,
          'sectionTitle': progress.sectionTitle,
        },
      ),
      borderRadius: BorderRadius.circular(28),
      child: Ink(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      progress.unitLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  ProgressChip(progress: progress.progress),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                progress.displayName,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                '${progress.totalWords} từ • ${progress.masteredWords} đã thuộc',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({super.key});

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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chưa có bài học trong cấp độ này',
            style: theme.textTheme.titleMedium,
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
