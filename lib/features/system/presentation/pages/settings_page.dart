import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _openPolicy() async {
    final uri = Uri.parse('https://10.220.130.117/newweb/nvidia/rack/f16/3f/all/ft');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch policy URL');
    }
  }

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
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
            child: ListTile(
              leading: Icon(Icons.pending_actions_outlined, color: theme.colorScheme.primary),
              title: const Text('Một số thiết lập đang hoàn thiện'),
              subtitle: const Text('Các tuỳ chọn mới sẽ được cập nhật sớm, một số nút hiện ở trạng thái "Sắp ra mắt".'),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Giao diện',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: SwitchListTile.adaptive(
              value: false,
              title: const Text('Chế độ tối'),
              subtitle: const Text('Sắp ra mắt: Bật tắt giao diện tối và ghi nhớ trên thiết bị.'),
              onChanged: null,
              secondary: Chip(
                label: const Text('Sắp ra mắt'),
                backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                labelStyle: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
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
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Chính sách & quyền riêng tư'),
                  subtitle: const Text('Mở tài liệu trực tuyến.'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _openPolicy(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
