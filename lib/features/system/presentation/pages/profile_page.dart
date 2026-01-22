import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../vocabulary/data/models/user_stats_model.dart';
import '../../../vocabulary/domain/usecases/get_user_stats.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with WidgetsBindingObserver, RouteAware {
  late GetUserStatsUseCase _getUserStats;
  late Future<UserStats> _userStatsFuture;
  late RouteObserver<ModalRoute<dynamic>> _routeObserver;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _routeObserver = Get.find<RouteObserver<ModalRoute<dynamic>>>();
    _getUserStats = Get.find<GetUserStatsUseCase>();
    _refreshStats();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ⭐ Register trang này với RouteObserver
    _routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPush() {
    print('👁️ [PROFILE] Trang được push');
  }

  @override
  void didPopNext() {
    print('👁️ [PROFILE] Quay lại từ trang khác → Refresh streak');
    _refreshStats();
  }

  @override
  void didPop() {
    print('👁️ [PROFILE] Trang bị pop');
  }

  @override
  void dispose() {
    _routeObserver.unsubscribe(this); // ⭐ Unsubscribe khi dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ⭐ Khi trang được resume (user quay lại từ practice)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('👁️ [PROFILE] App resumed → Refresh streak');
      _refreshStats();
    }
  }

  // 🔄 Hàm refresh dữ liệu từ database
  void _refreshStats() {
    print('🔄 [PROFILE] _refreshStats() được gọi');
    setState(() {
      _userStatsFuture = _getUserStats().then((stats) {
        print('📊 [PROFILE] Dữ liệu từ database:');
        print('   💰 totalExp: ${stats.totalExp}');
        print('   🔥 currentStreak: ${stats.currentStreak}');
        print('   📖 totalWordsMastered: ${stats.totalWordsMastered}');
        print('   📅 lastStudyDate: ${stats.lastStudyDate}');
        return stats;
      }).catchError((e) {
        print('❌ [PROFILE] Lỗi load dữ liệu: $e');
        throw e;  // ⭐ Throw error để FutureBuilder xử lý
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ & thành tích'),
        actions: [
          // ⟲ Nút refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshStats,
            tooltip: 'Tải lại dữ liệu',
          ),
        ],
      ),
      body: FutureBuilder<UserStats>(
        future: _userStatsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang tải dữ liệu...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('❌ Lỗi: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshStats,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final userStats = snapshot.data;
          if (userStats == null) {
            return const Center(child: Text('❌ Không có dữ liệu'));
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: theme.colorScheme.primary.withAlpha(41),
                    child: Icon(Icons.emoji_emotions_outlined, color: theme.colorScheme.primary, size: 36),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Học viên HSK',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Hành trình gõ tiếng Trung của bạn được ghi lại tại đây.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // ⭐ Kinh nghiệm
              _StatTile(
                icon: Icons.star,
                title: 'Kinh nghiệm',
                value: '${userStats.totalExp} EXP',
                description: 'Điểm kinh nghiệm tích lũy từ hoạt động học tập.',
              ),
              const SizedBox(height: 16),
              // 🔥 Chuỗi ngày học
              _StatTile(
                icon: Icons.local_fire_department,
                title: 'Chuỗi ngày học',
                value: '${userStats.currentStreak} ngày',
                description: 'Giữ nhịp luyện tập mỗi ngày để trí nhớ bền vững.',
              ),
              const SizedBox(height: 16),
              // 📖 Từ thuần thục
              _StatTile(
                icon: Icons.auto_awesome,
                title: 'Từ đã thuần thục',
                value: '${userStats.totalWordsMastered}',
                description: 'Số lượng từ đã hoàn thành đủ vòng luyện tập.',
              ),
              const SizedBox(height: 16),
              // ❤️ Câu yêu thích
              _StatTile(
                icon: Icons.favorite_outline,
                title: 'Câu ví dụ yêu thích',
                value: '${userStats.totalFavorites}',
                description: 'Bạn đã đánh dấu ${userStats.totalFavorites} câu để luyện lại.',
              ),
              const SizedBox(height: 32),
              Text(
                'Kỹ năng luyện gõ',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: const [
                  _SkillChip(label: 'Đánh máy pinyin'),
                  _SkillChip(label: 'Nhập nghĩa tiếng Việt'),
                  _SkillChip(label: 'Gõ câu hoàn chỉnh'),
                  _SkillChip(label: 'Phản xạ hội thoại'),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String value;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(31),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(description, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      label: Text(label),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      backgroundColor: theme.colorScheme.primary.withAlpha(26),
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
