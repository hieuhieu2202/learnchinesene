import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt hệ thống'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Tuỳ chỉnh trải nghiệm học tập',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            'Điều chỉnh giọng đọc, chủ đề và mức độ nhắc nhở để hành trình học gõ tiếng Trung phù hợp với bạn nhất.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          SwitchListTile.adaptive(
            value: true,
            title: const Text('Bật giọng đọc tiêu chuẩn (TTS)'),
            subtitle: const Text('Phát âm mẫu cho từng câu luyện gõ.'),
            onChanged: (_) {},
          ),
          const Divider(height: 32),
          SwitchListTile.adaptive(
            value: false,
            title: const Text('Chế độ nền tối'),
            subtitle: const Text('Giúp tập trung khi học vào buổi tối.'),
            onChanged: (_) {},
          ),
          const Divider(height: 32),
          SwitchListTile.adaptive(
            value: true,
            title: const Text('Nhắc ôn tập hằng ngày'),
            subtitle: const Text('Gợi ý thời điểm review từ cần củng cố.'),
            onChanged: (_) {},
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.restore),
            label: const Text('Đặt lại tiến trình học'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
