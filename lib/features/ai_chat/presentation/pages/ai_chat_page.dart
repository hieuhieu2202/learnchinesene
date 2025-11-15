import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/ai_message.dart';
import '../controllers/ai_chat_controller.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  late final TextEditingController _inputController;
  late final ScrollController _scrollController;
  late final Worker _messagesWorker;
  AiChatController get controller => Get.find<AiChatController>();

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
    _scrollController = ScrollController();
    _messagesWorker = ever<List<AiMessage>>(controller.messages, (_) {
      if (!mounted) return;
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messagesWorker.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hán Ngữ Bot'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withOpacity(0.04),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Column(
                    children: [
                      Expanded(
                        child: Obx(() {
                          final messages = controller.messages;
                          return ListView.separated(
                            controller: _scrollController,
                            padding: EdgeInsets.zero,
                            itemCount: messages.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              final isUser = message.isUser;
                              final alignment =
                                  isUser ? Alignment.centerRight : Alignment.centerLeft;
                              final background = isUser
                                  ? theme.colorScheme.primaryContainer
                                  : theme.colorScheme.surfaceContainerHighest;
                              final textStyle = theme.textTheme.bodyMedium?.copyWith(
                                    color: isUser
                                        ? theme.colorScheme.onPrimaryContainer
                                        : theme.colorScheme.onSurface,
                                  ) ??
                                  TextStyle(
                                    color: isUser
                                        ? theme.colorScheme.onPrimaryContainer
                                        : theme.colorScheme.onSurface,
                                  );
                              return Align(
                                alignment: alignment,
                                child: Container(
                                  constraints: const BoxConstraints(maxWidth: 420),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: background,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Text(
                                    message.text,
                                    style: textStyle,
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      Obx(
                        () => controller.isLoading.value
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2.5),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 12),
                      _ChatInputBar(
                        controller: _inputController,
                        onSubmit: _handleSubmit,
                        chatController: controller,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit(String value) {
    controller.sendMessage(value);
    _inputController.clear();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    _scrollController.animateTo(
      position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  const _ChatInputBar({
    required this.controller,
    required this.onSubmit,
    required this.chatController,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmit;
  final AiChatController chatController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            minLines: 1,
            maxLines: 4,
            autofocus: true,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: 'Nhập câu hỏi về tiếng Trung...',
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onSubmitted: onSubmit,
          ),
        ),
        const SizedBox(width: 12),
        Obx(() {
          final isLoading = chatController.isLoading.value;
          return ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    onSubmit(controller.text);
                  },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(14),
            ),
            child: const Icon(Icons.send_rounded),
          );
        }),
      ],
    );
  }
}
