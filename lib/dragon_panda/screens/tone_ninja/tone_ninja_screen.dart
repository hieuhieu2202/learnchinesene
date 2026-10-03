import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// REQUIRED ASSETS:
/// 1. Background: assets/images/backgrounds/tone_ninja_bg.png
/// 2. Character:  assets/images/characters/panda_ninja.png
class ToneNinjaScreen extends StatelessWidget {
  final VoidCallback onBack;

  const ToneNinjaScreen({Key? key, required this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ==========================================
          // LAYER 0: PURE CHINESE VILLAGE AT NIGHT BACKGROUND
          // REQUIRED ASSET: assets/images/backgrounds/tone_ninja_bg.png
          // ==========================================
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgrounds/tone_ninja_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // Night Vignette
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.35),
            ),
          ),

          // ==========================================
          // LAYER 1: FLUTTER GAMEPLAY UI & NINJA PANDA
          // ==========================================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  // App Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.35), shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                          onPressed: onBack,
                        ),
                      ),
                      const Text(
                        'Tone Ninja',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          shadows: [Shadow(color: Colors.black, blurRadius: 6)],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.35), shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white, size: 22),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),

                  // Score & 3 Hearts
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          '⭐ 3 / 10',
                          style: TextStyle(
                            color: AppColors.primaryGold,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                          ),
                        ),
                        Row(
                          children: [
                            Text('❤️', style: TextStyle(fontSize: 20)),
                            SizedBox(width: 4),
                            Text('❤️', style: TextStyle(fontSize: 20)),
                            SizedBox(width: 4),
                            Text('❤️', style: TextStyle(fontSize: 20)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Ninja Panda Character Overlay
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: Image.asset(
                      'assets/images/characters/panda_ninja.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(child: Text('🥷🐼', style: TextStyle(fontSize: 64))),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Speaker Button & Target Pinyin
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.cardCream,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.volume_up_rounded, color: AppColors.primaryBlue, size: 32),
                        SizedBox(width: 12),
                        Text(
                          'mǎ',
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // 4 Tone Options in 2x2 Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.1,
                    children: [
                      _buildToneCard('mǎ (3)', isCorrect: true),
                      _buildToneCard('mā (1)'),
                      _buildToneCard('má (2)'),
                      _buildToneCard('mà (4)'),
                    ],
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToneCard(String text, {bool isCorrect = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xFF20D66B).withOpacity(0.28) : Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCorrect ? AppColors.successGreen : Colors.white30,
          width: isCorrect ? 2.5 : 1.2,
        ),
        boxShadow: [
          if (isCorrect)
            BoxShadow(
              color: AppColors.successGreen.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: isCorrect ? AppColors.successGreen : Colors.white,
          ),
        ),
      ),
    );
  }
}
