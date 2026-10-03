import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/answer_button.dart';

/// REQUIRED ASSETS:
/// 1. Background: assets/images/backgrounds/quick_answer_bg.png
class QuickAnswerScreen extends StatelessWidget {
  final VoidCallback onBack;

  const QuickAnswerScreen({Key? key, required this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ==========================================
          // LAYER 0: PURE PURPLE/BLUE NIGHT FANTASY BACKGROUND
          // REQUIRED ASSET: assets/images/backgrounds/quick_answer_bg.png
          // ==========================================
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgrounds/quick_answer_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // Night Atmospheric Vignette
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.38),
            ),
          ),

          // ==========================================
          // LAYER 1: FLUTTER GAMEPLAY UI
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
                        'Trả lời nhanh',
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

                  // Timer & Score Pills
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primaryGold, width: 1.5),
                          ),
                          child: Row(
                            children: const [
                              Text('⏱️', style: TextStyle(fontSize: 16)),
                              SizedBox(width: 6),
                              Text('15s', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryGold)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white30, width: 1.2),
                          ),
                          child: Row(
                            children: const [
                              Text('🏆', style: TextStyle(fontSize: 16)),
                              SizedBox(width: 6),
                              Text('10', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Question Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.cardCream,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.cardCreamBorder, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: const [
                        Icon(Icons.volume_up_rounded, color: AppColors.primaryBlue, size: 36),
                        SizedBox(height: 8),
                        Text(
                          '电脑',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'diàn nǎo',
                          style: TextStyle(fontSize: 16, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // 2x2 Answer Grid
                  Row(
                    children: [
                      AnswerButton(
                        text: 'máy tính',
                        state: AnswerButtonState.correct,
                        onTap: () {},
                      ),
                      const SizedBox(width: 12),
                      AnswerButton(
                        text: 'điện thoại',
                        state: AnswerButtonState.idle,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      AnswerButton(
                        text: 'màn hình',
                        state: AnswerButtonState.idle,
                        onTap: () {},
                      ),
                      const SizedBox(width: 12),
                      AnswerButton(
                        text: 'bàn phím',
                        state: AnswerButtonState.idle,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
