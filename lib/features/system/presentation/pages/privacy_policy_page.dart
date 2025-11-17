import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chính sách & quyền riêng tư'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chúng tôi tôn trọng quyền riêng tư của bạn và chỉ sử dụng dữ liệu để cải thiện trải nghiệm học tiếng Trung.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              '• Tiến trình học được lưu cục bộ trên thiết bị.
• Âm thanh và yêu cầu AI chỉ được gửi khi bạn chủ động thực hiện.
• Bạn có thể đặt lại dữ liệu bất kỳ lúc nào trong phần cài đặt.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Nếu bạn có câu hỏi về quyền riêng tư, vui lòng liên hệ đội ngũ hỗ trợ.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
