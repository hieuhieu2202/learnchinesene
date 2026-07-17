import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../database/db_helper.dart';
import '../widgets/stat_card.dart';
import 'hsk_screen.dart';
import 'review_screen.dart';
import 'speaking_screen.dart';
import 'stats_screen.dart';
import '../features/hanzi_writing/screens/hanzi_writing_home_screen.dart';
import '../core/responsive/responsive_layout.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, num>> stats;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    stats = DbHelper.instance.getStats();
  }

  Future<void> _refresh() async {
    setState(() {
      stats = DbHelper.instance.getStats();
    });
    await stats;
  }

  Widget _buildHomeDashboard() {
    return RefreshIndicator(
      onRefresh: _refresh,
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
                          onPressed: () => Navigator.pushNamed(
                              context, StatsScreen.routeName),
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
                            onPressed: () => Navigator.pushNamed(
                                context, HskScreen.routeName),
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
                    FutureBuilder<Map<String, num>>(
                      future: stats,
                      builder: (context, snap) {
                        final s = snap.data ?? const <String, num>{};
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
                                value:
                                    '${(s['speakingAverage'] ?? 0).round()}%',
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
                      },
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
                      onTap: () =>
                          Navigator.pushNamed(context, ReviewScreen.routeName),
                    ),
                    const SizedBox(height: 10),
                    _Action(
                      icon: Icons.record_voice_over_rounded,
                      title: 'Luyện phát âm',
                      subtitle: 'Cải thiện phát âm với điểm số tức thì',
                      color: AppColors.orange,
                      onTap: () => Navigator.pushNamed(
                        context,
                        SpeakingScreen.routeName,
                        arguments: const {'standalone': true},
                      ),
                    ),
                    const SizedBox(height: 10),
                    _Action(
                      icon: Icons.menu_book_rounded,
                      title: 'Kho từ vựng',
                      subtitle: 'Xem từ theo cấp độ HSK và bài học',
                      color: AppColors.red,
                      onTap: () =>
                          Navigator.pushNamed(context, HskScreen.routeName),
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

  @override
  Widget build(BuildContext context) {
    final body = SafeArea(
      child: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeDashboard(),
          const HanziWritingHomeScreen(),
        ],
      ),
    );

    return ResponsiveLayout(
      mobile: Scaffold(
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.school_outlined),
                selectedIcon: Icon(Icons.school),
                label: 'Học'),
            NavigationDestination(
                icon: Icon(Icons.draw_outlined),
                selectedIcon: Icon(Icons.draw),
                label: 'Viết chữ'),
          ],
        ),
      ),
      tablet: Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (i) => setState(() => _currentIndex = i),
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                    icon: Icon(Icons.school_outlined),
                    selectedIcon: Icon(Icons.school),
                    label: Text('Học')),
                NavigationRailDestination(
                    icon: Icon(Icons.draw_outlined),
                    selectedIcon: Icon(Icons.draw),
                    label: Text('Viết chữ')),
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
              selectedIndex: _currentIndex,
              onDestinationSelected: (i) => setState(() => _currentIndex = i),
              destinations: const [
                NavigationRailDestination(
                    icon: Icon(Icons.school_outlined),
                    selectedIcon: Icon(Icons.school),
                    label: Text('Học')),
                NavigationRailDestination(
                    icon: Icon(Icons.draw_outlined),
                    selectedIcon: Icon(Icons.draw),
                    label: Text('Viết chữ')),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: body),
          ],
        ),
      ),
    );
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
