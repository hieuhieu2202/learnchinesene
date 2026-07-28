import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import 'controller/lessons_controller.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  final controller = Get.put(LessonsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Bài học chuyên đề AI',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Obx(() {
        return Column(
          children: [
            // Level selector header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      const Text(
                        'Cấp độ HSK:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: AppColors.ink),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButton<int>(
                          value: controller.selectedLevel.value,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: List.generate(6, (index) {
                            final lvl = index + 1;
                            return DropdownMenuItem(
                              value: lvl,
                              child: Text('HSK $lvl',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                            );
                          }),
                          onChanged: (val) {
                            if (val != null) {
                              controller.selectedLevel.value = val;
                              controller.loadTopics();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Topics Grid/List
            Expanded(
              child: controller.isTopicsLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : controller.topics.isEmpty
                      ? const Center(child: Text('Không tìm thấy bài học nào.'))
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: controller.topics.length,
                          itemBuilder: (context, index) {
                            final topic = controller.topics[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      AppColors.red.withOpacity(0.1),
                                  foregroundColor: AppColors.red,
                                  child: Text('${index + 1}'),
                                ),
                                title: Text(
                                  topic['title'] ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.ink),
                                ),
                                subtitle: Text(
                                  topic['description'] ?? '',
                                  style: const TextStyle(
                                      color: AppColors.muted, fontSize: 13),
                                ),
                                trailing: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                    color: AppColors.muted),
                                onTap: () =>
                                    _openLessonDetail(topic['title'] ?? ''),
                              ),
                            );
                          },
                        ),
            ),
          ],
        );
      }),
    );
  }

  void _openLessonDetail(String topicTitle) {
    controller.loadLessonDetail(topicTitle);
    Get.to(() => const _LessonDetailView());
  }
}

class _LessonDetailView extends StatelessWidget {
  const _LessonDetailView();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LessonsController>();
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Obx(() => Text(
                controller.lessonTitle.value,
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              )),
          bottom: const TabBar(
            labelColor: AppColors.red,
            unselectedLabelColor: AppColors.muted,
            indicatorColor: AppColors.red,
            tabs: [
              Tab(text: 'Hội thoại'),
              Tab(text: 'Từ vựng'),
              Tab(text: 'Ngữ pháp'),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isDetailLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            physics: const BouncingScrollPhysics(),
            children: [
              _buildDialogueTab(controller),
              _buildVocabTab(controller),
              _buildGrammarTab(controller),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDialogueTab(LessonsController controller) {
    if (controller.dialogue.isEmpty) {
      return const Center(child: Text('Không có dữ liệu hội thoại.'));
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: controller.dialogue.length,
      itemBuilder: (context, index) {
        final line = controller.dialogue[index];
        final speaker = line['speaker'] ?? 'A';
        final isA = speaker == 'A';

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: isA ? AppColors.red : AppColors.orange,
                foregroundColor: Colors.white,
                radius: 18,
                child: Text(speaker,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  child: InkWell(
                    onTap: () => controller.speak(line['zh'] ?? ''),
                    borderRadius: BorderRadius.circular(22),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  line['zh'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.ink,
                                    fontFamily: 'FZKaiTiPinyin',
                                  ),
                                ),
                              ),
                              const Icon(Icons.volume_up_rounded,
                                  size: 20, color: AppColors.red),
                            ],
                          ),
                          const Divider(height: 16),
                          Text(
                            line['vi'] ?? '',
                            style: const TextStyle(
                                fontSize: 14, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVocabTab(LessonsController controller) {
    if (controller.keyVocabulary.isEmpty) {
      return const Center(child: Text('Không có từ vựng trọng tâm.'));
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: controller.keyVocabulary.length,
      itemBuilder: (context, index) {
        final item = controller.keyVocabulary[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['hanzi'] ?? '',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['pinyin'] ?? '',
                        style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.orange,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['meaning_vi'] ?? '',
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => controller.speak(item['hanzi'] ?? ''),
                  icon:
                      const Icon(Icons.volume_up_rounded, color: AppColors.red),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrammarTab(LessonsController controller) {
    if (controller.grammarPoints.isEmpty) {
      return const Center(child: Text('Không có điểm ngữ pháp nào.'));
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: controller.grammarPoints.length,
      itemBuilder: (context, index) {
        final gp = controller.grammarPoints[index];
        final examples = gp['examples'] as List<dynamic>? ?? [];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    gp['point'] ?? 'Điểm ngữ pháp',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.orange),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  gp['explanation_vi'] ?? '',
                  style: const TextStyle(
                      fontSize: 14, height: 1.45, color: AppColors.ink),
                ),
                if (examples.isNotEmpty) ...[
                  const Divider(height: 24),
                  const Text(
                    'Câu ví dụ:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.muted),
                  ),
                  const SizedBox(height: 8),
                  ...examples.map((ex) {
                    final map = ex as Map<String, String>;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  map['zh'] ?? '',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.ink),
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    controller.speak(map['zh'] ?? ''),
                                icon: const Icon(Icons.volume_up_rounded,
                                    size: 18, color: AppColors.muted),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          Text(
                            map['pinyin'] ?? '',
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.orange,
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            map['vi'] ?? '',
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.muted),
                          ),
                        ],
                      ),
                    );
                  }),
                ]
              ],
            ),
          ),
        );
      },
    );
  }
}
