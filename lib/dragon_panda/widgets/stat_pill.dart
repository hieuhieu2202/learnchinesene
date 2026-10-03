import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StatPill extends StatelessWidget {
  final String emoji;
  final String count;
  final String label;
  final Color color;

  const StatPill({
    Key? key,
    required this.emoji,
    required this.count,
    required this.label,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
