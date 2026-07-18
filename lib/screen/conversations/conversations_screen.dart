import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/primary_button.dart';
import 'controller/conversations_controller.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final controller = Get.put(ConversationsController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Hội thoại tình huống AI',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Settings Panel Card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Cấp độ HSK:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.ink),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Obx(() => DropdownButton<int>(
                                  value: controller.selectedLevel.value,
                                  isExpanded: true,
                                  underline: Container(
                                      height: 1,
                                      color: AppColors.muted.withOpacity(0.3)),
                                  items: List.generate(6, (index) {
                                    final lvl = index + 1;
                                    return DropdownMenuItem(
                                      value: lvl,
                                      child: Text('HSK $lvl',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600)),
                                    );
                                  }),
                                  onChanged: (val) {
                                    if (val != null) {
                                      controller.selectedLevel.value = val;
                                    }
                                  },
                                )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller.topicController,
                        decoration: InputDecoration(
                          hintText:
                              'Nhập chủ đề hội thoại (Ví dụ: Mua sắm, Du lịch...)',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: AppColors.muted.withOpacity(0.3)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Obx(() => controller.isLoading.value
                          ? const Center(child: CircularProgressIndicator())
                          : PrimaryButton(
                              label: 'Tạo hội thoại',
                              onPressed: controller.startConversation,
                            )),
                    ],
                  ),
                ),
              ),
            ),

            // Conversation Chat View
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const SizedBox();
                }

                if (controller.lines.isEmpty) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.forum_rounded,
                            size: 80,
                            color: AppColors.muted.withOpacity(0.2),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Bắt đầu cuộc trò chuyện',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Chọn cấp độ HSK và nhập chủ đề mong muốn để AI tạo đoạn hội thoại chất lượng cao.',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: AppColors.muted, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    if (controller.currentTopic.value.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        color: AppColors.orange.withOpacity(0.1),
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Text(
                          'Chủ đề: ${controller.currentTopic.value}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.orange),
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: controller.lines.length + 1,
                        itemBuilder: (context, index) {
                          if (index == controller.lines.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Obx(() => controller.isMoreLoading.value
                                    ? const CircularProgressIndicator()
                                    : TextButton.icon(
                                        onPressed: controller.loadMoreLines,
                                        icon: const Icon(
                                            Icons.add_comment_rounded),
                                        label: const Text('Tiếp tục hội thoại'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: AppColors.red,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 12),
                                          side: const BorderSide(
                                              color: AppColors.red),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16)),
                                        ),
                                      )),
                              ),
                            );
                          }

                          final line = controller.lines[index];
                          final turn = line['turn'] as int? ?? 1;
                          final isSpeakerA = turn % 2 == 1;

                          final bubbleColor = isSpeakerA
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.surfaceContainerHighest;
                          final alignment = isSpeakerA
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.end;
                          final paddingLeft = isSpeakerA ? 0.0 : 40.0;
                          final paddingRight = isSpeakerA ? 40.0 : 0.0;

                          return Padding(
                            padding: EdgeInsets.fromLTRB(
                                paddingLeft, 4, paddingRight, 12),
                            child: Column(
                              crossAxisAlignment: alignment,
                              children: [
                                Text(
                                  isSpeakerA ? 'Speaker A' : 'Speaker B',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.muted.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Material(
                                  color: bubbleColor,
                                  borderRadius: BorderRadius.circular(18),
                                  child: InkWell(
                                    onTap: () =>
                                        controller.speak(line['zh'] ?? ''),
                                    borderRadius: BorderRadius.circular(18),
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  line['zh'] ?? '',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.ink,
                                                    fontFamily: 'FZKaiTiPinyin',
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(
                                                  Icons.volume_up_rounded,
                                                  size: 18,
                                                  color: AppColors.red),
                                            ],
                                          ),
                                          const Divider(height: 16),
                                          Text(
                                            line['vi'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppColors.muted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
