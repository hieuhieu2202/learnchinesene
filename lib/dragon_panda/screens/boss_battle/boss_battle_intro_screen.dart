import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/game_button.dart';

/// REQUIRED ASSETS:
/// 1. Background: assets/images/backgrounds/boss_intro_bg.png
/// 2. Characters: assets/images/characters/dragon_fire.png
///                assets/images/characters/panda_archer.png
class BossBattleIntroScreen extends StatelessWidget {
  final VoidCallback onStartGame;
  final VoidCallback onBack;

  const BossBattleIntroScreen({
    Key? key,
    required this.onStartGame,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ==========================================
          // LAYER 0: PURE EPIC BATTLEFIELD BACKGROUND (NO CHARACTERS, NO UI)
          // REQUIRED ASSET: assets/images/backgrounds/boss_intro_bg.png
          // ==========================================
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgrounds/boss_intro_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // ==========================================
          // LAYER 1: FOREGROUND CHARACTERS
          // ==========================================
          // 1. Fire Dragon on Upper Right
          Positioned(
            top: 70,
            right: -25,
            width: 270,
            height: 270,
            child: Image.asset(
              'assets/images/characters/dragon_fire.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Center(child: Text('🐲🔥', style: TextStyle(fontSize: 80))),
            ),
          ),

          // 2. Panda Archer on Lower Left
          Positioned(
            bottom: 220,
            left: 10,
            width: 210,
            height: 210,
            child: Image.asset(
              'assets/images/characters/panda_archer.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Center(child: Text('🐼🏹', style: TextStyle(fontSize: 70))),
            ),
          ),

          // ==========================================
          // LAYER 2: FLUTTER UI & INFO CARD
          // ==========================================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Back Button Top-Left
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        onPressed: onBack,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Epic Title & Subtitle
                  const Text(
                    'Boss Battle',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: Colors.black, blurRadius: 14, offset: Offset(0, 4)),
                        Shadow(color: Color(0xFFD32F2F), blurRadius: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Đánh bại Boss bằng kiến thức tiếng Trung!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGold,
                      shadows: [
                        Shadow(color: Colors.black, blurRadius: 8, offset: Offset(0, 2)),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Bottom Info Card (3 Bullet Points)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF140718).withOpacity(0.88),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.24), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: const [
                        _FeatureRow(icon: '📖', text: 'Học từ vựng qua trận chiến'),
                        SizedBox(height: 12),
                        _FeatureRow(icon: '⚔️', text: 'Càng đúng càng mạnh'),
                        SizedBox(height: 12),
                        _FeatureRow(icon: '⭐', text: 'Thu thập phần thưởng hấp dẫn'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Start Button
                  GameButton(
                    text: '⚔️ Bắt đầu chơi',
                    gradient: AppColors.orangeGoldGradient,
                    height: 56,
                    borderRadius: 24,
                    onTap: onStartGame,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String icon;
  final String text;

  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 18))),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
