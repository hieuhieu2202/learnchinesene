import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/game_button.dart';

/// REQUIRED ASSETS:
/// 1. Background: assets/images/backgrounds/defeat_bg.png
/// 2. Character:  assets/images/characters/panda_dizzy.png
class BossBattleDefeatScreen extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onBackToHub;

  const BossBattleDefeatScreen({
    Key? key,
    required this.onRetry,
    required this.onBackToHub,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ==========================================
          // LAYER 0: PURE DARK DAMAGED BATTLEFIELD
          // REQUIRED ASSET: assets/images/backgrounds/defeat_bg.png
          // ==========================================
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgrounds/defeat_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // Dark Smoky Vignette
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),

          // ==========================================
          // LAYER 1: FLUTTER UI & CHARACTERS
          // ==========================================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Defeat Title
                  const Text(
                    'Thất bại!',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: AppColors.dangerRed,
                      shadows: [
                        Shadow(color: Colors.black, blurRadius: 10, offset: Offset(0, 3)),
                        Shadow(color: Color(0xFFB62028), blurRadius: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  const Text(
                    'Đừng bỏ cuộc!\nHãy luyện tập thêm để mạnh hơn nhé!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFE2E8F0),
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Tired Panda
                  SizedBox(
                    width: 170,
                    height: 170,
                    child: Image.asset(
                      'assets/images/characters/panda_dizzy.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(child: Text('🐼💫🥀', style: TextStyle(fontSize: 64))),
                    ),
                  ),
                  const SizedBox(height: 38),

                  // "Thử lại" Button (Orange)
                  GameButton(
                    text: 'Thử lại',
                    gradient: AppColors.orangeGoldGradient,
                    onTap: onRetry,
                  ),
                  const SizedBox(height: 12),

                  // "Về Game Hub" Button (Dark Blue)
                  GameButton(
                    text: 'Về Game Hub',
                    gradient: AppColors.darkBlueGradient,
                    shadowColor: const Color(0xFF0F172A),
                    onTap: onBackToHub,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
