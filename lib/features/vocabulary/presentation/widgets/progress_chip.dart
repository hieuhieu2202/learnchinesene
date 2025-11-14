import 'package:flutter/material.dart';

class ProgressChip extends StatelessWidget {
  const ProgressChip({
    super.key,
    required this.progress,
  });

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 12),
        Text('${(progress * 100).toStringAsFixed(0)}%'),
      ],
    );
  }
}
