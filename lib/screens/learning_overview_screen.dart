import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../database/db_helper.dart';
import '../core/responsive/responsive_layout.dart';
import 'quiz_screen.dart';
import 'speaking_screen.dart';
import 'word_list_screen.dart';

class LearningOverviewScreen extends StatefulWidget {
  static const routeName = '/overview';
  const LearningOverviewScreen({super.key});
  @override
  State<LearningOverviewScreen> createState() => _LearningOverviewScreenState();
}

class _LearningOverviewScreenState extends State<LearningOverviewScreen> {
  int unitId = 0;
  String title = 'Bài học';
  bool loaded = false;
  Future<Map<String, int>>? metrics;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (loaded) return;
    loaded = true;
    final a =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    unitId = (a?['unitId'] as int?) ?? 0;
    title = '${a?['unitTitle'] ?? 'Bài học'}';
    metrics = DbHelper.instance.getUnitMetrics(unitId);
  }

  void go(String route) => Navigator.pushNamed(
    context,
    route,
    arguments: {'unitId': unitId, 'unitTitle': title},
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: FutureBuilder<Map<String, int>>(
      future: metrics,
      builder: (context, snap) {
        if (!snap.hasData)
          return const Center(child: CircularProgressIndicator());
        final m = snap.data!;
        final words = m['words'] ?? 0;
        final examples = m['examples'] ?? 0;
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: ResponsiveHelper.contentMaxWidth(context)),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                ResponsiveHelper.horizontalPadding(context),
                0,
                ResponsiveHelper.horizontalPadding(context),
                32,
              ),
              children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.redDark, AppColors.red],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BÀI HỌC TIẾP THEO',
                    style: TextStyle(
                      color: Color(0xCCFFFFFF),
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _metric(Icons.style_rounded, '$words từ'),
                      const SizedBox(width: 18),
                      _metric(
                        Icons.chat_bubble_outline_rounded,
                        '$examples câu mẫu',
                      ),
                      const SizedBox(width: 18),
                      _metric(
                        Icons.schedule_rounded,
                        '${(words * .7).ceil()} phút',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            const Text(
              'Chọn hoạt động',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            _activity(
              Icons.style_rounded,
              'Học từ vựng',
              'Ghi nhớ từ mới qua thẻ học trực quan',
              AppColors.red,
              () => go(WordListScreen.routeName),
            ),
            _activity(
              Icons.quiz_rounded,
              'Bắt đầu kiểm tra',
              'Luyện nghĩa, pinyin và nghe hiểu',
              AppColors.orange,
              () => go(QuizScreen.routeName),
            ),
            _activity(
              Icons.mic_rounded,
              'Luyện phát âm',
              'Nhận phản hồi phát âm ngay lập tức',
              AppColors.success,
              () => go(SpeakingScreen.routeName),
            ),
            ],
            ),
          ),
        );
      },
    ),
  );
  Widget _metric(IconData i, String t) => Expanded(
    child: Row(
      children: [
        Icon(i, color: Colors.white70, size: 17),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            t,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
  Widget _activity(
    IconData icon,
    String t,
    String sub,
    Color c,
    VoidCallback tap,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(21),
      child: InkWell(
        onTap: tap,
        borderRadius: BorderRadius.circular(21),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: c.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: c),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sub,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    ),
  );
}
