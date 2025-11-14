import 'package:flutter/material.dart';

import '../../domain/entities/word.dart';

class WordListItem extends StatelessWidget {
  const WordListItem({
    super.key,
    required this.word,
    this.onTap,
  });

  final Word word;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusLabel = word.mastered ? 'Đã thuộc' : 'Chưa học';
    final statusColor = word.mastered
        ? theme.colorScheme.primary
        : theme.colorScheme.outline.withOpacity(0.6);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  word.word,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      word.transliteration,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      word.translation,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    word.mastered ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: statusColor,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    statusLabel,
                    style: theme.textTheme.labelSmall?.copyWith(color: statusColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
