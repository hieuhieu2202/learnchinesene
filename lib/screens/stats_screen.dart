import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../database/db_helper.dart';
import '../core/responsive/responsive_layout.dart';
import '../widgets/stat_card.dart';

class StatsScreen extends StatelessWidget {
  static const routeName = '/stats';
  const StatsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Tiến độ của bạn',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    body: FutureBuilder<Map<String, num>>(
      future: DbHelper.instance.getStats(),
      builder: (context, snap) {
        if (!snap.hasData)
          return const Center(child: CircularProgressIndicator());
        final s = snap.data!;
        final correct = s['correct'] ?? 0;
        final wrong = s['wrong'] ?? 0;
        final accuracy = correct + wrong == 0
            ? 0
            : correct / (correct + wrong) * 100;
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: ResponsiveHelper.contentMaxWidth(context)),
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.horizontalPadding(context),
                vertical: 24,
              ),
              children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.redDark, AppColors.red, AppColors.orange],
                ),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${s['mastered']?.toInt() ?? 0}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    'từ đã thành thạo',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 250,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.35,
              ),
              children: [
                StatCard(
                  icon: Icons.auto_stories_rounded,
                  value: '${s['learned']?.toInt() ?? 0}',
                  label: 'Từ đã học',
                ),
                StatCard(
                  icon: Icons.gps_fixed_rounded,
                  value: '${accuracy.round()}%',
                  label: 'Độ chính xác',
                  color: AppColors.success,
                ),
                StatCard(
                  icon: Icons.error_outline_rounded,
                  value: '${s['wrong']?.toInt() ?? 0}',
                  label: 'Câu trả lời sai',
                  color: AppColors.error,
                ),
                StatCard(
                  icon: Icons.mic_rounded,
                  value: '${(s['speakingAverage'] ?? 0).round()}%',
                  label: 'Điểm phát âm',
                  color: AppColors.orange,
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Text(
              'Tiếp tục cố gắng',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Những buổi học ngắn và đều đặn là cách tốt nhất để ghi nhớ từ vựng.',
              style: TextStyle(color: AppColors.muted, height: 1.5),
            ),
          ],
            ),
          ),
        );
      },
    ),
  );
}
