import 'package:flutter/material.dart';

class GameHpBar extends StatelessWidget {
  final int currentHp;
  final int maxHp;
  final Color barColor;
  final double height;
  final double? width;
  final String label;

  const GameHpBar({
    Key? key,
    required this.currentHp,
    required this.maxHp,
    required this.barColor,
    this.height = 14,
    this.width,
    this.label = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double fraction = (currentHp / maxHp).clamp(0.0, 1.0);
    return Container(
      width: width ?? 140,
      height: height,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.2),
      ),
      child: Stack(
        children: [
          AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            widthFactor: fraction,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [barColor.withOpacity(0.85), barColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(height / 2),
                boxShadow: [
                  BoxShadow(
                    color: barColor.withOpacity(0.4),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          if (label.isNotEmpty)
            Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [
                    Shadow(color: Colors.black, blurRadius: 2),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
