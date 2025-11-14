import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../controllers/section_list_controller.dart';
import '../widgets/progress_chip.dart';

class SectionListPage extends GetView<SectionListController> {
  const SectionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách bài học'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.hskGroups.length,
          itemBuilder: (context, index) {
            final group = controller.hskGroups[index];
            return Card(
              child: ExpansionTile(
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        group.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      child: ProgressChip(progress: group.progress),
                    ),
                  ],
                ),
                children: [
                  if (group.sections.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        'Chưa có bài học trong cấp độ này.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  else
                    ...group.sections.map(
                      (section) => ListTile(
                        title: Text(section.unitTitle),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: ProgressChip(progress: section.progress),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Get.toNamed(
                          AppRoutes.wordList,
                          arguments: {
                            'sectionId': section.sectionId,
                            'sectionTitle': section.unitTitle,
                          },
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 12),
        );
      }),
    );
  }
}
