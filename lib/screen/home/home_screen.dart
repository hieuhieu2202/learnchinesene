import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/game/game_art.dart';
import '../../widgets/game_network_image.dart';
import '../../widgets/game_button.dart';
import '../../widgets/game_stat_pill.dart';
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
import '../game_hub/game_hub_screen.dart';
import '../../features/system/presentation/pages/profile_page.dart';
import '../../features/system/presentation/pages/settings_page.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeController get controller => Get.find<HomeController>();

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
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .07),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(
                              color: AppColors.gold,
                              shape: BoxShape.circle,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: const GameNetworkImage(
                              url: GameArt.pandaAvatar,
                              fit: BoxFit.cover,
                              fallbackEmoji: '🐼',
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '你好，勇士!',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Hôm nay chinh phục thêm một chút nhé.',
                                  style: TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
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
                    ),
                    const SizedBox(height: 26),
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .18),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          const GameNetworkImage(
                            url: GameArt.homeBackground,
                            fit: BoxFit.cover,
                            fallbackEmoji: '🏯',
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: .08),
                                  Colors.black.withValues(alpha: .56),
                                ],
                              ),
                            ),
                          ),
                          const Positioned(
                            right: -6,
                            top: 8,
                            width: 190,
                            height: 220,
                            child: GameNetworkImage(
                              url: GameArt.pandaArcher,
                              fit: BoxFit.contain,
                              fallbackEmoji: '🐼',
                            ),
                          ),
                          Positioned(
                            left: 20,
                            right: 20,
                            bottom: 18,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'HÀNH TRÌNH HÔM NAY',
                                  style: TextStyle(
                                    color: Color(0xFFFFE8A3),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Lên cấp tiếng Trung\nqua từng thử thách',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    height: 1.08,
                                    fontWeight: FontWeight.w900,
                                    shadows: [
                                      Shadow(color: Colors.black54, blurRadius: 8),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                GameButton(
                                  label: 'Tiếp tục học',
                                  onPressed: () => Get.to(() => const HskScreen()),
                                ),
                              ],
                            ),
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
                          GameStatPill(
                            emoji: '📖',
                            value: '${s['learned']?.toInt() ?? 0}',
                            label: 'Từ đã học',
                          ),
                          const SizedBox(width: 10),
                          GameStatPill(
                            emoji: '🎤',
                            value: '${(s['speakingAverage'] ?? 0).round()}%',
                            label: 'Phát âm',
                          ),
                          const SizedBox(width: 10),
                          GameStatPill(
                            emoji: '⭐',
                            value: '${s['correct']?.toInt() ?? 0}',
                            label: 'Câu đúng',
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 20),
                    _Action(
                      icon: Icons.sports_esports_rounded,
                      title: 'Game Hub · 冒险模式',
                      subtitle: 'Boss Battle, Tone Ninja, Flashcard Quest và hơn thế nữa',
                      color: AppColors.orange,
                      onTap: () => Get.to(() => const GameHubScreen()),
                    ),
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
                      onTap: () => Get.to(() => const ConversationsScreen()),
                    ),
                    const SizedBox(height: 10),
                    _Action(
                      icon: Icons.school_rounded,
                      title: 'Bài học chuyên đề AI',
                      subtitle: 'Tự động biên soạn bài học và ngữ pháp',
                      color: AppColors.red,
                      onTap: () => Get.to(() => const LessonsScreen()),
                    ),
                    const SizedBox(height: 10),
                    _Action(
                      icon: Icons.assignment_turned_in_rounded,
                      title: 'Thi thử HSK với AI',
                      subtitle:
                          'Chấm điểm và nhận xét chi tiết từ giáo viên AI',
                      color: AppColors.success,
                      onTap: () => Get.to(() => const HskExamScreen()),
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
              onTap: () => Get.to(() => const LessonsScreen()),
            ),
            const SizedBox(height: 12),
            _Action(
              icon: Icons.forum_rounded,
              title: 'Hội thoại tình huống AI',
              subtitle: 'Luyện giao tiếp qua các chủ đề thông minh',
              color: AppColors.orange,
              onTap: () => Get.to(() => const ConversationsScreen()),
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
              onTap: () => Get.to(() => const HskExamScreen()),
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
