import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import 'controller/history_controller.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final controller = Get.put(HistoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Lịch sử & Phân tích',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.defaultDialog(
                title: 'Xóa lịch sử',
                middleText:
                    'Bạn có chắc chắn muốn xóa toàn bộ lịch sử học tập?',
                textConfirm: 'Xóa',
                textCancel: 'Hủy',
                confirmTextColor: Colors.white,
                buttonColor: AppColors.red,
                onConfirm: () {
                  Get.back();
                  controller.clearAll();
                },
              );
            },
            icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.red),
            tooltip: 'Xóa tất cả',
          )
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.historyItems.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off_rounded,
                      size: 70, color: AppColors.muted),
                  SizedBox(height: 12),
                  Text(
                    'Chưa có lịch sử học tập',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: AppColors.ink),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Lịch sử dịch thuật, hội thoại và thi thử của bạn sẽ xuất hiện ở đây.',
                    style: TextStyle(color: AppColors.muted, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: controller.historyItems.length,
            itemBuilder: (context, index) {
              final item = controller.historyItems[index];
              Color tagColor = AppColors.red;
              if (item.type == 'Hội thoại') tagColor = AppColors.orange;
              if (item.type == 'Thi HSK') tagColor = AppColors.success;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: tagColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.type,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: tagColor),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _formatTime(item.timestamp),
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.muted),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      item.summary,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                          fontSize: 14),
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.muted),
                  onTap: () => _showHistoryDetail(context, item),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  String _formatTime(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} - ${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return isoString;
    }
  }

  void _showHistoryDetail(BuildContext context, dynamic item) {
    final type = item.type;
    final content = item.content;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$type - Chi tiết',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink),
              ),
              const Divider(height: 24),
              if (type == 'Dịch thuật') ...[
                Text(
                    'Nguồn: ${content['source_lang']} ➔ Đích: ${content['target_lang']}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text('Nội dung dịch:',
                    style: TextStyle(color: AppColors.muted, fontSize: 12)),
                const SizedBox(height: 4),
                Text(content['hanzi'] ?? '',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink)),
                if (content['pinyin'] != null)
                  Text(content['pinyin'],
                      style: const TextStyle(
                          color: AppColors.orange,
                          fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                const Text('Nghĩa tiếng Việt:',
                    style: TextStyle(color: AppColors.muted, fontSize: 12)),
                Text(content['vi_meaning'] ?? '',
                    style: const TextStyle(fontSize: 15, color: AppColors.ink)),
              ] else if (type == 'Hội thoại') ...[
                Text('Chủ đề: ${content['topic']}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: AppColors.orange)),
                const SizedBox(height: 12),
                ...((content['lines'] as List<dynamic>? ?? []).map((line) {
                  final speaker =
                      (line['turn'] as int? ?? 1) % 2 == 1 ? 'A' : 'B';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Speaker $speaker:',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.muted)),
                        Text(line['zh'] ?? '',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.ink)),
                        Text(line['pinyin'] ?? '',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.orange)),
                        Text(line['vi'] ?? '',
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.muted)),
                      ],
                    ),
                  );
                })),
              ] else if (type == 'Thi HSK') ...[
                Text('Điểm số: ${content['score']}/${content['total']}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.red)),
                const SizedBox(height: 12),
                if (content['analysis'] != null) ...[
                  const Text('Nhận xét giáo viên:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.orange)),
                  const SizedBox(height: 4),
                  Text(content['analysis']['overall_assessment'] ?? '',
                      style:
                          const TextStyle(height: 1.4, color: AppColors.ink)),
                ],
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
