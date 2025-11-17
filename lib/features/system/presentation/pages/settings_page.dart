import 'package:flutter/material.dart';

import 'privacy_policy_page.dart';

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
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Điều chỉnh nhanh',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  value: true,
                  title: const Text('Phát âm mẫu (TTS)'),
                  subtitle: const Text('Nghe lại câu ví dụ khi luyện gõ.'),
                  onChanged: (_) {},
                ),
                const Divider(height: 0),
                SwitchListTile.adaptive(
                  value: false,
                  title: const Text('Chế độ tối'),
                  subtitle: const Text('Giảm chói và giữ tập trung vào buổi tối.'),
                  onChanged: (_) {},
                ),
                const Divider(height: 0),
                SwitchListTile.adaptive(
                  value: true,
                  title: const Text('Nhắc ôn tập hằng ngày'),
                  subtitle: const Text('Thông báo nhẹ để bạn không quên luyện câu.'),
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Tài khoản & dữ liệu',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: const Text('Đặt lại tiến trình học'),
                  subtitle: const Text('Xoá số liệu luyện tập và bắt đầu lại.'),
                  onTap: () {},
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Chính sách & quyền riêng tư'),
                  subtitle: const Text('Đọc thông tin chi tiết trong ứng dụng.'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyPage(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
