import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../database/db_helper.dart';
import '../../models/hsk_level.dart';
import '../../widgets/empty_state_widget.dart';
import '../../core/responsive/responsive_layout.dart';
import '../unit/unit_screen.dart';
import 'controller/hsk_controller.dart';
import '../../features/subscription/controller/subscription_controller.dart';
import '../../core/helper/upgrade_dialog_helper.dart';

class HskScreen extends StatelessWidget {
  const HskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HskController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chọn cấp độ HSK',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.hasError.value) {
          return const EmptyStateWidget(
            icon: Icons.cloud_off_rounded,
            title: 'Không thể tải cấp độ',
            message: 'Không thể mở dữ liệu bài học ngoại tuyến.',
          );
        }
        final levels = controller.levels;
        if (levels.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.layers_outlined,
            title: 'Chưa có cấp độ',
            message: 'Không tìm thấy cấp độ HSK trong cơ sở dữ liệu.',
          );
        }
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: ResponsiveHelper.contentMaxWidth(context)),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.horizontalPadding(context),
                vertical: 24,
              ),
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Text(
                        'Học theo lộ trình HSK với tốc độ của riêng bạn. Mọi bài học đều dùng được ngoại tuyến.',
                        style: TextStyle(color: AppColors.muted, height: 1.5),
                      ),
                    ),
                  ),
                  SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 450,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      mainAxisExtent: 110,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _LevelCard(level: levels[index], index: index),
                      childCount: levels.length,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.level, required this.index});
  final HskLevel level;
  final int index;

  @override
  Widget build(BuildContext context) {
    final subController = Get.find<SubscriptionController>();

    return FutureBuilder<List<Object>>(
        future: Future.wait<Object>([
          DbHelper.instance.getUnitCountForLevel(level.id),
          DbHelper.instance.getLevelProgress(level.id),
        ]),
        builder: (context, snap) {
          final count = snap.hasData ? snap.data![0] as int : 0;
          final progress = snap.hasData ? snap.data![1] as double : 0.0;
          return Obx(() {
            final isUnlocked = subController.isLevelUnlocked(level.order);
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0B3B1518),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () {
                if (isUnlocked) {
                  Get.to(
                    () => const UnitScreen(),
                    arguments: {'hskLevelId': level.id, 'hskTitle': level.title},
                  );
                } else {
                  UpgradeDialogHelper.showUpgradeDialog(
                    context: context,
                    title: 'Mở khóa HSK ${level.order}',
                    message: 'Tính năng này yêu cầu nâng cấp gói cước để học toàn bộ từ vựng cấp độ HSK ${level.order}.',
                    benefits: level.order <= 3
                        ? ['Học toàn bộ từ vựng HSK 1-3', 'Lưu tiến độ trên đám mây']
                        : ['Mở khóa toàn bộ HSK 1-6', 'Hội thoại AI không giới hạn', 'Thi thử HSK với AI'],
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.red,
                            index.isEven ? AppColors.orange : AppColors.redDark,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${level.order}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            level.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$count bài • hoàn thành ${(progress * 100).round()}%',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 10),
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 7,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      isUnlocked ? Icons.arrow_forward_ios_rounded : Icons.lock_rounded,
                      size: 16,
                      color: isUnlocked ? AppColors.muted : AppColors.orange,
                    ),
                  ],
                ),
              ),
            ),
          );
          });
        },
      );
  }
}
