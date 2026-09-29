import 'package:flutter/material.dart';

enum BossBattleAnswerVisualState {
  idle,
  correct,
  wrong,
  disabled,
}

class BossBattleAnswerButton extends StatelessWidget {
  const BossBattleAnswerButton({
    super.key,
    required this.answer,
    required this.state,
    required this.onTap,
  });

  final String answer;
  final BossBattleAnswerVisualState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = _paletteFor(state);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.border, width: 2),
        boxShadow: [
          BoxShadow(
            color: palette.glow,
            blurRadius: state == BossBattleAnswerVisualState.idle ? 8 : 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      answer,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.foreground,
                        fontSize: answer.length <= 4 ? 24 : 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (state == BossBattleAnswerVisualState.correct) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF1F9A63)),
                  ],
                  if (state == BossBattleAnswerVisualState.wrong) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.cancel_rounded, color: Color(0xFFD94848)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _AnswerPalette _paletteFor(BossBattleAnswerVisualState state) {
    switch (state) {
      case BossBattleAnswerVisualState.correct:
        return const _AnswerPalette(
          background: Color(0xFFE9FBEF),
          border: Color(0xFF2AAA6E),
          foreground: Color(0xFF174D34),
          glow: Color(0x442AAA6E),
        );
      case BossBattleAnswerVisualState.wrong:
        return const _AnswerPalette(
          background: Color(0xFFFFECEC),
          border: Color(0xFFD94848),
          foreground: Color(0xFF7B2424),
          glow: Color(0x44D94848),
        );
      case BossBattleAnswerVisualState.disabled:
        return const _AnswerPalette(
          background: Color(0xFFF2EEE9),
          border: Color(0xFFD8D0C8),
          foreground: Color(0xFF827970),
          glow: Color(0x11000000),
        );
      case BossBattleAnswerVisualState.idle:
        return const _AnswerPalette(
          background: Color(0xFFFFFBF3),
          border: Color(0xFFE6B565),
          foreground: Color(0xFF2E2520),
          glow: Color(0x18000000),
        );
    }
  }
}

class _AnswerPalette {
  const _AnswerPalette({
    required this.background,
    required this.border,
    required this.foreground,
    required this.glow,
  });

  final Color background;
  final Color border;
  final Color foreground;
  final Color glow;
}
