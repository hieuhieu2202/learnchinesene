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
      appBar: AppBar(
        title: Text('HSK ${controller.hskLevel}'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final sections = controller.sections;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _LevelHeader(theme: theme, controller: controller),
            const SizedBox(height: 16),
            if (sections.isEmpty)
              _EmptyState(theme: theme)
            else
              ...List.generate(
                sections.length,
                (index) => Padding(
                  padding: EdgeInsets.only(top: index == 0 ? 0 : 12),
                  child: _UnitCard(
                    index: index,
                    progress: sections[index],
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _LevelHeader extends StatelessWidget {
  const _LevelHeader({
    required this.theme,
    required this.controller,
  });

  final ThemeData theme;
  final SectionListController controller;

  @override
  Widget build(BuildContext context) {
    final totalWords = controller.totalWords;
    final masteredWords = controller.masteredWords;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tổng quan cấp độ',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: controller.progress),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${controller.sections.length} bài học',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Text(
                  '${masteredWords}/${totalWords == 0 ? 0 : totalWords} từ đã thuộc',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  const _UnitCard({
    required this.index,
    required this.progress,
  });

  final int index;
  final SectionProgress progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => Get.toNamed(
        AppRoutes.wordList,
        arguments: {
          'sectionId': progress.sectionId,
          'sectionTitle': progress.sectionTitle,
        },
      ),
      child: Ink(
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withOpacity(0.6),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Unit ${index + 1}'),
                  ),
                  const Spacer(),
                  ProgressChip(progress: progress.progress),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                progress.displayName,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                '${progress.totalWords} từ • ${progress.masteredWords} đã thuộc',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
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
  const _EmptyState({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
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
      ),
    );
  }
}
