import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../services/history_service.dart';
import '../../../../core/responsive/responsive_layout.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final HistoryService _historyService = Get.find<HistoryService>();

  bool _isDarkMode = Get.isDarkMode;
  double _speechRate = 0.5;
  List<HistoryItem> _history = [];
  bool _isLoadingStats = true;

  int _totalActivities = 0;
  String _mostUsedFeature = 'Chưa có';
  Map<String, int> _featureUsage = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoadingStats = true;
    });

    try {
      final list = await _historyService.getHistory();
      final Map<String, int> usage = {};
      for (var item in list) {
        usage[item.type] = (usage[item.type] ?? 0) + 1;
      }

      String favorite = 'Chưa có';
      int maxCount = 0;
      usage.forEach((key, val) {
        if (val > maxCount) {
          maxCount = val;
          favorite = key;
        }
      });

      setState(() {
        _history = list;
        _totalActivities = list.length;
        _featureUsage = usage;
        _mostUsedFeature = favorite;
      });
    } catch (_) {}

    setState(() {
      _isLoadingStats = false;
    });
  }

  Future<void> _clearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text(
            'Bạn có chắc chắn muốn xóa toàn bộ lịch sử sử dụng AI không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Xóa hết'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _historyService.clearHistory();
      _loadStats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa toàn bộ lịch sử.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxWidth = ResponsiveHelper.contentMaxWidth(context);

    // Sort features by count descending
    final sortedFeatures = _featureUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cài đặt & Thống kê',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Cài đặt hệ thống section
              Text(
                'Thiết lập ứng dụng',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      SwitchListTile.adaptive(
                        value: _isDarkMode,
                        title: const Text('Chế độ tối'),
                        subtitle:
                            const Text('Thay đổi chủ đề hiển thị hệ thống'),
                        onChanged: (val) {
                          setState(() {
                            _isDarkMode = val;
                          });
                          Get.changeThemeMode(
                              val ? ThemeMode.dark : ThemeMode.light);
                        },
                      ),
                      const Divider(indent: 16, endIndent: 16),
                      ListTile(
                        title: const Text('Tốc độ đọc câu ví dụ (TTS)'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Slider(
                              value: _speechRate,
                              min: 0.2,
                              max: 1.5,
                              divisions: 13,
                              label: '${_speechRate.toStringAsFixed(1)}x',
                              onChanged: (val) {
                                setState(() {
                                  _speechRate = val;
                                });
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Tốc độ hiện tại: ${_speechRate.toStringAsFixed(1)}x',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Thống kê hoạt động section
              Text(
                'Thống kê hoạt động học tập AI',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _isLoadingStats
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        // Stats Overview Grid
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.4,
                          children: [
                            _buildStatCard(
                              title: 'Hoạt động',
                              value: '$_totalActivities',
                              color: theme.colorScheme.primary,
                              icon: Icons.history_edu_rounded,
                            ),
                            _buildStatCard(
                              title: 'Yêu thích',
                              value: _mostUsedFeature,
                              color: AppColors.orange,
                              icon: Icons.star_rounded,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Detailed distribution chart
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tần suất sử dụng tính năng',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                const SizedBox(height: 16),
                                if (sortedFeatures.isEmpty)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Text(
                                        'Chưa có dữ liệu thống kê.',
                                        style:
                                            TextStyle(color: AppColors.muted),
                                      ),
                                    ),
                                  )
                                else
                                  ...sortedFeatures.map((entry) {
                                    final feature = entry.key;
                                    final count = entry.value;
                                    final pct = _totalActivities > 0
                                        ? count / _totalActivities
                                        : 0.0;
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 14),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(feature,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600)),
                                              Text('$count lần',
                                                  style: const TextStyle(
                                                      color: AppColors.muted)),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: LinearProgressIndicator(
                                              value: pct,
                                              minHeight: 8,
                                              backgroundColor: theme
                                                  .colorScheme.surfaceVariant,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      theme
                                                          .colorScheme.primary),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

              const SizedBox(height: 28),

              // Data Management
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: ListTile(
                  leading: const Icon(Icons.delete_sweep_rounded,
                      color: AppColors.error),
                  title: const Text('Xóa dữ liệu lịch sử'),
                  subtitle: const Text(
                      'Xóa vĩnh viễn các lượt dịch, hội thoại và đề thi cũ'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _clearAllData,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
