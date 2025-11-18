import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ & thành tích'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.16),
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
          const SizedBox(height: 16),
          Card(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ListTile(
              leading: Chip(
                label: const Text('Sắp ra mắt'),
                backgroundColor: theme.colorScheme.primary.withOpacity(0.14),
                labelStyle: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              title: const Text('Trang thống kê đang được hoàn thiện'),
              subtitle: const Text('Số liệu sẽ đồng bộ tự động khi tính năng chính thức ra mắt.'),
            ),
          ),
          const SizedBox(height: 32),
          _StatTile(
            icon: Icons.auto_awesome,
            title: 'Từ đã thuần thục',
            value: '48',
            description: 'Số lượng từ đã hoàn thành đủ 10 vòng luyện gõ.',
          ),
          const SizedBox(height: 16),
          _StatTile(
            icon: Icons.calendar_today_outlined,
            title: 'Chuỗi ngày học',
            value: '12 ngày',
            description: 'Giữ nhịp luyện tập mỗi ngày để trí nhớ bền vững.',
          ),
          const SizedBox(height: 16),
          _StatTile(
            icon: Icons.favorite_outline,
            title: 'Câu ví dụ yêu thích',
            value: '9',
            description: 'Bạn đã đánh dấu 9 câu để luyện lại thường xuyên.',
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
            color: Colors.black.withOpacity(0.04),
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
              color: theme.colorScheme.primary.withOpacity(0.12),
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
      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
