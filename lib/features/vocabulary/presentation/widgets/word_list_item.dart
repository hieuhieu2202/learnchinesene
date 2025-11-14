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
    return ListTile(
      title: Text(
        word.word,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      subtitle: Text('${word.transliteration} • ${word.translation}'),
      trailing: Icon(
        word.mastered ? Icons.check_circle : Icons.radio_button_unchecked,
        color: word.mastered ? Colors.green : null,
      ),
      onTap: onTap,
    );
  }
}
