import 'package:flutter/material.dart';

class ProgressBarWidget extends StatelessWidget {
  final int current;
  final int total;

  const ProgressBarWidget({
    super.key,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final safeTotal = total == 0 ? 1 : total;
    final progress = current / safeTotal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Câu $current/$total'),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress.clamp(0, 1),
          minHeight: 10,
          borderRadius: BorderRadius.circular(20),
        ),
      ],
    );
  }
}
