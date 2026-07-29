import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/stat_card.dart';
import 'package:get/get.dart';
import '../hsk/hsk_screen.dart';
import '../review/review_screen.dart';
import '../speaking/speaking_screen.dart';
import '../stats/stats_screen.dart';
import 'controller/home_controller.dart';
import '../../features/hanzi_writing/screens/hanzi_writing_home_screen.dart';
import '../../core/responsive/responsive_layout.dart';
import '../translator/translator_screen.dart';
import '../conversations/conversations_screen.dart';
import '../lessons/lessons_screen.dart';
import '../hsk_exam/hsk_exam_screen.dart';
import '../history/history_screen.dart';
import '../dictionary/dictionary_screen.dart';
import '../flashcards/flashcards_screen.dart';
import '../hsk_quiz/hsk_quiz_screen.dart';
import '../../features/system/presentation/pages/profile_page.dart';
import '../../features/system/presentation/pages/settings_page.dart';
import '../../features/subscription/page/subscription_page.dart';
import '../../features/subscription/controller/subscription_controller.dart';
import '../../core/helper/upgrade_dialog_helper.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeController get controller => Get.find<HomeController>();

  void _runIfFeatureUnlocked(String featureKey, String title, String message, List<String> benefits, VoidCallback onUnlocked) {
    final subController = Get.find<SubscriptionController>();
    if (subController.isFeatureUnlocked(featureKey)) {
      onUnlocked();
    } else {
      UpgradeDialogHelper.showUpgradeDialog(
        context: context,
        title: title,
        message: message,
        benefits: benefits,
      );
    }
  }

  Widget _buildHomeDashboard() {
    return RefreshIndicator(
      onRefresh: () => controller.refreshStats(),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: ResponsiveHelper.contentMaxWidth(context)),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.red,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            '学',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '你好!',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Sẵn sàng cho bài học hôm nay?',
                                style: TextStyle(color: AppColors.muted),
                              ),
                            ],
                          ),
                        ),
                        IconButton.filledTonal(
                          onPressed: () => Get.to(() => const StatsScreen()),
                          icon: const Icon(Icons.insights_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.redDark,
                            AppColors.red,
                            AppColors.orange,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x30B4232C),
                            blurRadius: 24,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TIẾP TỤC HỌC',
                            style: TextStyle(
                              color: Color(0xCCFFFFFF),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Chinh phục tiếng Trung\ntừng từ mỗi ngày',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 22),
                          FilledButton.icon(
                            onPressed: () => Get.to(() => const HskScreen()),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.redDark,
                              minimumSize: const Size(0, 48),
                            ),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('Bắt đầu học'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    const Text(
                      'Tiến độ của bạn',
                      style:
                          TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    Obx(() {
                      final s = controller.stats;
                      return Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              icon: Icons.auto_stories_rounded,
                              value: '${s['learned']?.toInt() ?? 0}',
                              label: 'Từ đã học',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatCard(
                              icon: Icons.mic_rounded,
                              value: '${(s['speakingAverage'] ?? 0).round()}%',
                              label: 'Phát âm',
                              color: AppColors.orange,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatCard(
                              icon: Icons.task_alt_rounded,
                              value: '${s['correct']?.toInt() ?? 0}',
                              label: 'Đúng',
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 26),
                    const Text(
                      'Luyện tập theo cách của bạn',
                      style:
                          TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    _Action(
                      icon: Icons.replay_rounded,
                      title: 'Ôn lại từ sai',
                      subtitle: 'Biến những từ khó thành điểm mạnh',
                      color: AppColors.error,
                      onTap: () => Get.to(() => const ReviewScreen()),
                    ),
                    const SizedBox(height: 10),
                    _Action(
                      icon: Icons.record_voice_over_rounded,
                      title: 'Luyện phát âm',
                      subtitle: 'Cải thiện phát âm với điểm số tức thì',
                      color: AppColors.orange,
                      onTap: () => Get.to(
                        () => const SpeakingScreen(),
                        arguments: const {'standalone': true},
                      ),
                    ),
                    const SizedBox(height: 10),
                    _Action(
                      icon: Icons.menu_book_rounded,
                      title: 'Kho từ vựng',
                      subtitle: 'Xem từ theo cấp độ HSK và bài học',
                      color: AppColors.red,
                      onTap: () => Get.to(() => const HskScreen()),
                    ),
                    const SizedBox(height: 26),
                    const Text(
                      'Học tập & Tiện ích AI',
                      style:
                          TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    _Action(
                      icon: Icons.g_translate_rounded,
                      title: 'Dịch thuật & Quét ảnh AI',
                      subtitle: 'Dịch thuật Trung - Việt và quét chữ từ camera',
                      color: AppColors.redDark,
                      onTap: () => Get.to(() => const TranslatorScreen()),
                    ),
                    const SizedBox(height: 10),
                    _Action(
                      icon: Icons.forum_rounded,
                      title: 'Hội thoại tình huống AI',
                      subtitle: 'Luyện giao tiếp qua các chủ đề thông minh',
                      color: AppColors.orange,
                      onTap: () => _runIfFeatureUnlocked(
                        'ai_chat',
                        'Mở khóa Hội thoại AI',
                        'Tính năng trò chuyện tình huống thông minh yêu cầu nâng cấp gói cước Cao Cấp.',
                        const ['Giao tiếp tình huống không giới hạn', 'Phát âm và sửa lỗi thời gian thực', 'Đàm thoại AI thông minh'],
                        () => Get.to(() => const ConversationsScreen()),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _Action(
                      icon: Icons.school_rounded,
                      title: 'Bài học chuyên đề AI',
                      subtitle: 'Tự động biên soạn bài học và ngữ pháp',
                      color: AppColors.red,
                      onTap: () => _runIfFeatureUnlocked(
                        'lessons',
                        'Mở khóa Bài học AI',
                        'Tính năng biên soạn bài học ngữ pháp AI yêu cầu nâng cấp gói cước Cao Cấp.',
                        const ['Bài học ngữ pháp chuyên sâu tự động', 'Bài tập thực hành đi kèm phong phú', 'Hỏi đáp bài học trực tiếp'],
                        () => Get.to(() => const LessonsScreen()),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _Action(
                      icon: Icons.assignment_turned_in_rounded,
                      title: 'Thi thử HSK với AI',
                      subtitle:
                          'Chấm điểm và nhận xét chi tiết từ giáo viên AI',
                      color: AppColors.success,
                      onTap: () => _runIfFeatureUnlocked(
                        'hsk_exam',
                        'Mở khóa Thi thử AI',
                        'Tính năng làm đề thi thử và chấm điểm AI yêu cầu nâng cấp gói cước Cao Cấp.',
                        const ['Đề thi thử HSK 1-6 chuẩn cấu trúc', 'Chấm điểm và sửa bài chi tiết bằng AI', 'Xem lại lịch sử thi bất kỳ lúc nào'],
                        () => Get.to(() => const HskExamScreen()),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _Action(
                      icon: Icons.history_rounded,
                      title: 'Lịch sử & Phân tích',
                      subtitle:
                          'Xem lại các bản dịch, hội thoại và kết quả thi',
                      color: AppColors.muted,
                      onTap: () => Get.to(() => const HistoryScreen()),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLearningTab() {
    return Center(
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: ResponsiveHelper.contentMaxWidth(context)),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Học tập chuyên sâu',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 18),
            _Action(
              icon: Icons.menu_book_rounded,
              title: 'Kho từ vựng HSK',
              subtitle: 'Xem từ theo cấp độ HSK và bài học',
              color: AppColors.red,
              onTap: () => Get.to(() => const HskScreen()),
            ),
            const SizedBox(height: 12),
            _Action(
              icon: Icons.school_rounded,
              title: 'Bài học chuyên đề AI',
              subtitle: 'Tự động biên soạn bài học và ngữ pháp',
              color: AppColors.redDark,
              onTap: () => _runIfFeatureUnlocked(
                'lessons',
                'Mở khóa Bài học AI',
                'Tính năng biên soạn bài học ngữ pháp AI yêu cầu nâng cấp gói cước Cao Cấp.',
                const ['Bài học ngữ pháp chuyên sâu tự động', 'Bài tập thực hành đi kèm phong phú', 'Hỏi đáp bài học trực tiếp'],
                () => Get.to(() => const LessonsScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _Action(
              icon: Icons.forum_rounded,
              title: 'Hội thoại tình huống AI',
              subtitle: 'Luyện giao tiếp qua các chủ đề thông minh',
              color: AppColors.orange,
              onTap: () => _runIfFeatureUnlocked(
                'ai_chat',
                'Mở khóa Hội thoại AI',
                'Tính năng trò chuyện tình huống thông minh yêu cầu nâng cấp gói cước Cao Cấp.',
                const ['Giao tiếp tình huống không giới hạn', 'Phát âm và sửa lỗi thời gian thực', 'Đàm thoại AI thông minh'],
                () => Get.to(() => const ConversationsScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeTab() {
    return Center(
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: ResponsiveHelper.contentMaxWidth(context)),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Luyện tập & Thực hành',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 18),
            _Action(
              icon: Icons.record_voice_over_rounded,
              title: 'Luyện phát âm',
              subtitle: 'Cải thiện phát âm với điểm số tức thì',
              color: AppColors.orange,
              onTap: () => Get.to(
                () => const SpeakingScreen(),
                arguments: const {'standalone': true},
              ),
            ),
            const SizedBox(height: 12),
            _Action(
              icon: Icons.draw_rounded,
              title: 'Luyện viết chữ Hán',
              subtitle: 'Học viết chữ Hán theo thứ tự nét chuẩn',
              color: AppColors.red,
              onTap: () => Get.to(() => const HanziWritingHomeScreen()),
            ),
            const SizedBox(height: 12),
            _Action(
              icon: Icons.style_rounded,
              title: 'Flashcards ôn tập',
              subtitle: 'Ghi nhớ từ vựng với hiệu ứng lật thẻ 3D',
              color: AppColors.success,
              onTap: () => Get.to(() => const FlashcardsScreen()),
            ),
            const SizedBox(height: 12),
            _Action(
              icon: Icons.quiz_rounded,
              title: 'Trắc nghiệm HSK',
              subtitle: 'Bài tập trắc nghiệm ngẫu nhiên theo cấp độ HSK',
              color: AppColors.redDark,
              onTap: () => Get.to(() => const HskQuizScreen()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTab() {
    return Center(
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: ResponsiveHelper.contentMaxWidth(context)),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Tiến độ & Đánh giá',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 18),
            _Action(
              icon: Icons.insights_rounded,
              title: 'Thống kê chi tiết',
              subtitle: 'Theo dõi tiến trình và số liệu học tập của bạn',
              color: AppColors.orange,
              onTap: () => Get.to(() => const StatsScreen()),
            ),
            const SizedBox(height: 12),
            _Action(
              icon: Icons.assignment_turned_in_rounded,
              title: 'Thi thử HSK với AI',
              subtitle: 'Chấm điểm và nhận xét chi tiết từ giáo viên AI',
              color: AppColors.success,
              onTap: () => _runIfFeatureUnlocked(
                'hsk_exam',
                'Mở khóa Thi thử AI',
                'Tính năng làm đề thi thử và chấm điểm AI yêu cầu nâng cấp gói cước Cao Cấp.',
                const ['Đề thi thử HSK 1-6 chuẩn cấu trúc', 'Chấm điểm và sửa bài chi tiết bằng AI', 'Xem lại lịch sử thi bất kỳ lúc nào'],
                () => Get.to(() => const HskExamScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _Action(
              icon: Icons.history_rounded,
              title: 'Lịch sử & Phân tích',
              subtitle: 'Xem lại các bản dịch, hội thoại và kết quả thi',
              color: AppColors.muted,
              onTap: () => Get.to(() => const HistoryScreen()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalTab() {
    return Center(
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: ResponsiveHelper.contentMaxWidth(context)),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Cá nhân',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 18),
            _Action(
              icon: Icons.person_rounded,
              title: 'Hồ sơ người dùng',
              subtitle: 'Xem thông tin cá nhân và xếp hạng',
              color: AppColors.red,
              onTap: () => Get.to(() => const ProfilePage()),
            ),
            const SizedBox(height: 12),
            _Action(
              icon: Icons.workspace_premium_rounded,
              title: 'Nâng cấp Premium',
              subtitle: 'Mở khóa toàn bộ tính năng và bài học HSK',
              color: AppColors.orange,
              onTap: () => Get.to(() => const SubscriptionPage()),
            ),
            const SizedBox(height: 12),
            _Action(
              icon: Icons.g_translate_rounded,
              title: 'Từ điển Việt ↔ Trung',
              subtitle: 'Tra cứu từ bằng AI, hỗ trợ giọng nói',
              color: AppColors.orange,
              onTap: () => Get.to(() => const DictionaryScreen()),
            ),
            const SizedBox(height: 12),
            _Action(
              icon: Icons.settings_rounded,
              title: 'Cài đặt hệ thống',
              subtitle: 'Cấu hình âm thanh, tốc độ đọc, thông báo',
              color: AppColors.muted,
              onTap: () => Get.to(() => const SettingsPage()),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final body = SafeArea(
        child: IndexedStack(
          index: controller.currentIndex.value,
          children: [
            _buildHomeDashboard(),
            _buildLearningTab(),
            _buildPracticeTab(),
            _buildProgressTab(),
            _buildPersonalTab(),
          ],
        ),
      );

      return ResponsiveLayout(
        mobile: Scaffold(
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: controller.currentIndex.value,
            onDestinationSelected: controller.setIndex,
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Trang chủ'),
              NavigationDestination(
                  icon: Icon(Icons.school_outlined),
                  selectedIcon: Icon(Icons.school),
                  label: 'Học tập'),
              NavigationDestination(
                  icon: Icon(Icons.fitness_center_outlined),
                  selectedIcon: Icon(Icons.fitness_center),
                  label: 'Luyện tập'),
              NavigationDestination(
                  icon: Icon(Icons.insights_outlined),
                  selectedIcon: Icon(Icons.insights),
                  label: 'Tiến độ'),
              NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Cá nhân'),
            ],
          ),
        ),
        tablet: Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: controller.currentIndex.value,
                onDestinationSelected: controller.setIndex,
                labelType: NavigationRailLabelType.all,
                destinations: const [
                  NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: Text('Trang chủ')),
                  NavigationRailDestination(
                      icon: Icon(Icons.school_outlined),
                      selectedIcon: Icon(Icons.school),
                      label: Text('Học tập')),
                  NavigationRailDestination(
                      icon: Icon(Icons.fitness_center_outlined),
                      selectedIcon: Icon(Icons.fitness_center),
                      label: Text('Luyện tập')),
                  NavigationRailDestination(
                      icon: Icon(Icons.insights_outlined),
                      selectedIcon: Icon(Icons.insights),
                      label: Text('Tiến độ')),
                  NavigationRailDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: Text('Cá nhân')),
                ],
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: body),
            ],
          ),
        ),
        desktop: Scaffold(
          body: Row(
            children: [
              NavigationRail(
                extended: true,
                selectedIndex: controller.currentIndex.value,
                onDestinationSelected: controller.setIndex,
                destinations: const [
                  NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: Text('Trang chủ')),
                  NavigationRailDestination(
                      icon: Icon(Icons.school_outlined),
                      selectedIcon: Icon(Icons.school),
                      label: Text('Học tập')),
                  NavigationRailDestination(
                      icon: Icon(Icons.fitness_center_outlined),
                      selectedIcon: Icon(Icons.fitness_center),
                      label: Text('Luyện tập')),
                  NavigationRailDestination(
                      icon: Icon(Icons.insights_outlined),
                      selectedIcon: Icon(Icons.insights),
                      label: Text('Tiến độ')),
                  NavigationRailDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: Text('Cá nhân')),
                ],
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: body),
            ],
          ),
        ),
      );
    });
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
              ],
            ),
          ),
        ),
      );
}
