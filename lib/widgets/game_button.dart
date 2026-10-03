import 'package:flutter/material.dart';

class GameButton extends StatefulWidget {
  const GameButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.play_arrow_rounded,
    this.gradient = const LinearGradient(
      colors: [Color(0xFFFFC533), Color(0xFFFF8A1F)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  });

  final String label;
  final VoidCallback onPressed;
  final IconData icon;
  final Gradient gradient;

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => pressed = true),
      onTapCancel: () => setState(() => pressed = false),
      onTapUp: (_) {
        setState(() => pressed = false);
        widget.onPressed();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        transform: Matrix4.translationValues(0, pressed ? 4 : 0, 0),
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: .45)),
          boxShadow: pressed
              ? const []
              : [
                  const BoxShadow(
                    color: Color(0xFFB45309),
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .20),
                    offset: const Offset(0, 8),
                    blurRadius: 16,
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                shadows: [Shadow(color: Colors.black26, blurRadius: 3)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
