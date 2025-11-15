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
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                final messages = controller.messages;
                final isLoading = controller.isLoading.value;
                return ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: messages.length + (isLoading ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final isLoadingIndicator = isLoading && index == messages.length;
                    if (isLoadingIndicator) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        ),
                      );
                    }

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
                          borderRadius: BorderRadius.circular(16),
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
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: _ChatInputBar(
                controller: _inputController,
                onSubmit: _handleSubmit,
                chatController: controller,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit(String value) {
    if (controller.isLoading.value) return;
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
