import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../boss_battle/view/boss_battle_character_art.dart';
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
import '../duolingo/duo_game_center_screen.dart';
import '../game_hub/game_hub_screen.dart';

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
    return ColoredBox(
      color: const Color(0xFFFFFBF5),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveHelper.contentMaxWidth(context),
          ),
          child: RefreshIndicator(
            onRefresh: controller.refreshStats,
            color: const Color(0xFF2D9AF1),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 26),
              children: [
                _buildHomeHeader(),
                const SizedBox(height: 12),
                _buildHomeHero(),
                const SizedBox(height: 11),
                Obx(() {
                  final s = controller.stats;
                  return Row(
                    children: [
                      Expanded(
                        child: _HomeMetric(
                          icon: Icons.local_fire_department_rounded,
                          value: '${s['streak']?.toInt() ?? 7}',
                          label: 'Ngày học',
                          color: const Color(0xFF2F9DE2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _HomeMetric(
                          icon: Icons.menu_book_rounded,
                          value: '${s['learned']?.toInt() ?? 12}',
                          label: 'Bài học',
                          color: const Color(0xFF46AF52),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _HomeMetric(
                          icon: Icons.workspace_premium_rounded,
                          value:
                              '${((s['correct'] ?? 0) * 10).toInt() + 156}',
                          label: 'Điểm XP',
                          color: const Color(0xFFF3A325),
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 18),
                const _HomeSectionTitle(title: 'Bài học hôm nay'),
                const SizedBox(height: 9),
                _TodayLessonCard(
                  onTap: () => Get.to(() => const HskScreen()),
                ),
                const SizedBox(height: 18),
                const _HomeSectionTitle(title: 'Học nhanh'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _QuickTile(
                        icon: Icons.translate_rounded,
                        label: 'Từ vựng',
                        color: const Color(0xFFFF7438),
                        onTap: () => Get.to(() => const HskScreen()),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: _QuickTile(
                        icon: Icons.chat_bubble_rounded,
                        label: 'Ngữ pháp',
                        color: const Color(0xFF8757E8),
                        onTap: () => _runIfFeatureUnlocked(
                          'lessons',
                          'Mở khóa Bài học AI',
                          'Tính năng này yêu cầu nâng cấp.',
                          const ['Bài học ngữ pháp chuyên sâu'],
                          () => Get.to(() => const LessonsScreen()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: _QuickTile(
                        icon: Icons.headphones_rounded,
                        label: 'Luyện nghe',
                        color: const Color(0xFF26A9C8),
                        onTap: () =>
                            Get.to(() => const ConversationsScreen()),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: _QuickTile(
                        icon: Icons.mic_rounded,
                        label: 'Luyện nói',
                        color: const Color(0xFF29BA72),
                        onTap: () => Get.to(
                          () => const SpeakingScreen(),
                          arguments: const {'standalone': true},
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const _HomeSectionTitle(title: 'Thử thách hôm nay'),
                const SizedBox(height: 10),
                _ChallengeCard(
                  onTap: () => controller.setIndex(2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeHeader() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFFFEED3),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFFFCF8E),
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x16000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.all(3),
            child: BossBattleCharacterArt(
              kind: BossBattleCharacterKind.panda,
              size: 44,
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xin chào!',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Hôm nay cùng học tiếng Trung nào!',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4DF),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFFFD28C)),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🔥', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 3),
                  Text(
                    '12',
                    style: TextStyle(
                      color: Color(0xFFE76A16),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1),
              Text(
                'Ngày liên tiếp',
                style: TextStyle(
                  color: Color(0xFFAF7138),
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHomeHero() {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFFD8A4),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const CustomPaint(painter: _HomeHeroPainter()),
          Positioned(
            left: 16,
            top: 15,
            width: 205,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mỗi ngày một chút',
                  style: TextStyle(
                    color: Color(0xFF17354F),
                    fontSize: 21,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Học từ vựng, luyện nghe và chinh phục thử thách.',
                  maxLines: 2,
                  style: TextStyle(
                    color: Color(0xFF476477),
                    fontSize: 11.5,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 38,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2D9AF1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    onPressed: () => Get.to(() => const HskScreen()),
                    icon: const Icon(Icons.play_arrow_rounded, size: 19),
                    label: const Text(
                      'Bắt đầu học',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            right: -6,
            bottom: -7,
            child: BossBattleCharacterArt(
              kind: BossBattleCharacterKind.panda,
              size: 160,
            ),
          ),
        ],
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
              icon: Icons.games_rounded,
              title: 'Lộ Trình Học Tập',
              subtitle: 'Học tiếng Trung qua các trò chơi tương tác như Duolingo',
              color: Colors.blue,
              onTap: () => Get.to(() => const DuoGameCenterScreen()),
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

  Widget _buildGamesTab() {
    return const GameHubScreen();
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
      final index = controller.currentIndex.value.clamp(0, 4);
      final body = SafeArea(
        child: IndexedStack(
          index: index,
          children: [
            _buildHomeDashboard(),
            _buildLearningTab(),
            _buildGamesTab(),
            _buildProgressTab(),
            _buildPersonalTab(),
          ],
        ),
      );

      const destinations = <NavigationDestination>[
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Trang chủ',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book_rounded),
          label: 'Học tập',
        ),
        NavigationDestination(
          icon: Icon(Icons.sports_esports_outlined),
          selectedIcon: Icon(Icons.sports_esports_rounded),
          label: 'Trò chơi',
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart_rounded),
          label: 'Tiến độ',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Cá nhân',
        ),
      ];

      return ResponsiveLayout(
        mobile: Scaffold(
          backgroundColor: const Color(0xFFFFFAF2),
          body: body,
          bottomNavigationBar: NavigationBar(
            height: 68,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            indicatorColor: const Color(0xFFDCEEFF),
            selectedIndex: index,
            onDestinationSelected: controller.setIndex,
            labelBehavior:
                NavigationDestinationLabelBehavior.alwaysShow,
            destinations: destinations,
          ),
        ),
        tablet: Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: index,
                onDestinationSelected: controller.setIndex,
                labelType: NavigationRailLabelType.all,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: Text('Trang chủ'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.menu_book_outlined),
                    selectedIcon: Icon(Icons.menu_book_rounded),
                    label: Text('Học tập'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.sports_esports_outlined),
                    selectedIcon: Icon(Icons.sports_esports_rounded),
                    label: Text('Trò chơi'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.bar_chart_outlined),
                    selectedIcon: Icon(Icons.bar_chart_rounded),
                    label: Text('Tiến độ'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: Text('Cá nhân'),
                  ),
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
                selectedIndex: index,
                onDestinationSelected: controller.setIndex,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: Text('Trang chủ'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.menu_book_outlined),
                    selectedIcon: Icon(Icons.menu_book_rounded),
                    label: Text('Học tập'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.sports_esports_outlined),
                    selectedIcon: Icon(Icons.sports_esports_rounded),
                    label: Text('Trò chơi'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.bar_chart_outlined),
                    selectedIcon: Icon(Icons.bar_chart_rounded),
                    label: Text('Tiến độ'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: Text('Cá nhân'),
                  ),
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

class _HomeSectionTitle extends StatelessWidget {
  const _HomeSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.ink,
        fontSize: 17,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _TodayLessonCard extends StatelessWidget {
  const _TodayLessonCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF6FBFF),
      elevation: 0,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        borderRadius: BorderRadius.circular(19),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 88),
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: const Color(0xFFD5EAFE),
              width: 1.1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFDBF3FF),
                      Color(0xFFEAF8FF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Color(0xFF2E93D6),
                  size: 32,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Từ vựng cơ bản',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Chủ đề: Gia đình',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 7),
                    ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(99)),
                      child: LinearProgressIndicator(
                        value: .34,
                        minHeight: 5,
                        backgroundColor: Color(0xFFDCEAF4),
                        color: Color(0xFF2D9AF1),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 13),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D9AF1),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x332D9AF1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  'Bắt đầu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeMetric extends StatelessWidget {
  const _HomeMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0E8DE)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: color.withValues(alpha: .13),
              ),
            ),
            child: Center(
              child: Icon(icon, color: color, size: 25),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF0F8FF),
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0CF),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFF8B51B),
                  size: 29,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hoàn thành 10 câu hỏi',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 7),
                    LinearProgressIndicator(
                      value: .6,
                      minHeight: 7,
                      borderRadius: BorderRadius.all(Radius.circular(99)),
                      backgroundColor: Color(0xFFDDEAF4),
                      color: Color(0xFF2D9AF1),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                '6/10',
                style: TextStyle(
                  color: Color(0xFF4480A9),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 7),
              const Icon(
                Icons.card_giftcard_rounded,
                color: Color(0xFFFF8A1B),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeroPainter extends CustomPainter {
  const _HomeHeroPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF4FBFF),
            Color(0xFFDDF3FF),
            Color(0xFFFFEAC6),
          ],
        ).createShader(rect),
    );

    final mountain = Paint()..color = const Color(0xFFBFDDEB);
    final p = Path()
      ..moveTo(0, size.height * .68)
      ..lineTo(size.width * .18, size.height * .33)
      ..lineTo(size.width * .33, size.height * .62)
      ..lineTo(size.width * .48, size.height * .27)
      ..lineTo(size.width * .68, size.height * .64)
      ..lineTo(size.width * .84, size.height * .36)
      ..lineTo(size.width, size.height * .62)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(p, mountain);

    final ground = Paint()..color = const Color(0xFFB9DF8B);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * .68, size.width, size.height * .32),
      ground,
    );

    _pagoda(canvas, Offset(size.width * .17, size.height * .57), 36);
    _pagoda(canvas, Offset(size.width * .39, size.height * .61), 30);

    final blossom = Paint()..color = const Color(0xFFFF8FB5);
    for (var i = 0; i < 15; i++) {
      final x = size.width * (.02 + (i % 7) * .055);
      final y = size.height * (.72 + (i % 4) * .05);
      canvas.drawCircle(Offset(x, y), 4 + (i % 2), blossom);
    }
  }

  void _pagoda(Canvas canvas, Offset center, double s) {
    final roof = Paint()..color = const Color(0xFF315D73);
    final wall = Paint()..color = const Color(0xFFE2824C);

    canvas.drawRect(
      Rect.fromCenter(
        center: center.translate(0, s * .22),
        width: s * .8,
        height: s * .55,
      ),
      wall,
    );

    for (var floor = 0; floor < 2; floor++) {
      final y = center.dy - s * (.05 + floor * .3);
      final path = Path()
        ..moveTo(center.dx - s * .65, y)
        ..lineTo(center.dx, y - s * .19)
        ..lineTo(center.dx + s * .65, y)
        ..lineTo(center.dx + s * .48, y + s * .08)
        ..lineTo(center.dx - s * .48, y + s * .08)
        ..close();
      canvas.drawPath(path, roof);
    }
  }

  @override
  bool shouldRepaint(covariant _HomeHeroPainter oldDelegate) => false;
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
