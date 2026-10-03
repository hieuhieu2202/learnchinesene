import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/hp_bar.dart';
import '../../widgets/answer_button.dart';

/// REQUIRED ASSETS:
/// 1. Background: assets/images/backgrounds/boss_battle_portrait_bg.png
/// 2. Characters: assets/images/characters/panda_archer.png
///                assets/images/characters/dragon_fire.png
///                assets/images/characters/panda_avatar.png
class BossBattleGameplayScreen extends StatefulWidget {
  final VoidCallback onVictory;
  final VoidCallback onDefeat;
  final VoidCallback onExit;

  const BossBattleGameplayScreen({
    Key? key,
    required this.onVictory,
    required this.onDefeat,
    required this.onExit,
  }) : super(key: key);

  @override
  State<BossBattleGameplayScreen> createState() => _BossBattleGameplayScreenState();
}

class _BossBattleGameplayScreenState extends State<BossBattleGameplayScreen> {
  int bossHp = 320;
  final int maxBossHp = 500;
  int playerHp = 180;
  final int maxPlayerHp = 200;
  int combo = 3;

  bool isAnimating = false;
  String? feedbackText;
  int? floatingDamage;
  Color? damageColor;
  bool isWrongAttack = false;
  int? selectedAnswerIndex;

  double arrowProgress = 0.0;
  Timer? arrowTimer;

  void handleAnswer(int index) {
    if (isAnimating) return;
    setState(() {
      isAnimating = true;
      selectedAnswerIndex = index;
    });

    final bool isCorrect = (index == 0); // "uống" is correct for "喝"

    if (isCorrect) {
      // SCREEN 5: TRẢ LỜI ĐÚNG - PANDA TẤN CÔNG BOSS (-120)
      setState(() {
        combo += 1;
        feedbackText = 'Chính xác!';
        arrowProgress = 0.0;
      });

      const int steps = 20;
      int currentStep = 0;
      arrowTimer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
        currentStep++;
        if (currentStep >= steps) {
          timer.cancel();
          setState(() {
            arrowProgress = 1.0;
            floatingDamage = -120;
            damageColor = AppColors.primaryGold;
            bossHp = (bossHp - 120).clamp(0, maxBossHp);
          });

          Timer(const Duration(milliseconds: 900), () {
            if (bossHp <= 0) {
              widget.onVictory();
            } else {
              setState(() {
                isAnimating = false;
                feedbackText = null;
                floatingDamage = null;
                arrowProgress = 0.0;
                selectedAnswerIndex = null;
              });
            }
          });
        } else {
          setState(() {
            arrowProgress = currentStep / steps;
          });
        }
      });
    } else {
      // SCREEN 6: TRẢ LỜI SAI - RỒNG PHUN LỬA TẤN CÔNG PANDA (-30)
      setState(() {
        combo = 0;
        feedbackText = 'Sai rồi!';
        isWrongAttack = true;
      });

      Timer(const Duration(milliseconds: 400), () {
        setState(() {
          floatingDamage = -30;
          damageColor = AppColors.dangerRed;
          playerHp = (playerHp - 30).clamp(0, maxPlayerHp);
        });

        Timer(const Duration(milliseconds: 900), () {
          if (playerHp <= 0) {
            widget.onDefeat();
          } else {
            setState(() {
              isAnimating = false;
              feedbackText = null;
              floatingDamage = null;
              isWrongAttack = false;
              selectedAnswerIndex = null;
            });
          }
        });
      });
    }
  }

  @override
  void dispose() {
    arrowTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF140B18),
      body: Stack(
        children: [
          // ==========================================
          // LAYER 0: PURE BATTLE ARENA BACKGROUND
          // REQUIRED ASSET: assets/images/backgrounds/boss_battle_portrait_bg.png
          // ==========================================
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgrounds/boss_battle_portrait_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // ==========================================
          // LAYER 1: FOREGROUND CHARACTERS & VFX
          // ==========================================
          // 1. Panda Archer on Left Open Ground
          Positioned(
            left: 12,
            bottom: 300,
            width: 165,
            height: 165,
            child: Image.asset(
              'assets/images/characters/panda_archer.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Center(child: Text('🐼🏹', style: TextStyle(fontSize: 60))),
            ),
          ),

          // 2. Fire Dragon on Right Open Ground
          Positioned(
            right: -10,
            top: 80,
            width: 230,
            height: 230,
            child: Image.asset(
              'assets/images/characters/dragon_fire.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Center(child: Text('🐲🔥', style: TextStyle(fontSize: 75))),
            ),
          ),

          // 3. Arrow Flight VFX (When Correct Answer)
          if (arrowProgress > 0 && arrowProgress < 1.0)
            Positioned(
              left: 110 + (220 * arrowProgress),
              top: 260 - (90 * (1 - (arrowProgress - 0.5).abs() * 2)),
              child: Transform.rotate(
                angle: -0.3 + (arrowProgress * 0.6),
                child: const Text('🏹⚡', style: TextStyle(fontSize: 32, shadows: [Shadow(color: Colors.yellow, blurRadius: 10)])),
              ),
            ),

          // 4. Continuous Fire Breath Torrent VFX (When Wrong Answer)
          if (isWrongAttack)
            Positioned(
              right: 80,
              top: 150,
              width: 260,
              height: 140,
              child: const Center(
                child: Text(
                  '🔥🔥🔥🔥🔥',
                  style: TextStyle(fontSize: 48, shadows: [Shadow(color: Colors.yellow, blurRadius: 18)]),
                ),
              ),
            ),

          // 5. Floating Damage Text (-120 or -30)
          if (floatingDamage != null)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: damageColor ?? Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(color: (damageColor ?? Colors.white).withOpacity(0.5), blurRadius: 16),
                  ],
                ),
                child: Text(
                  '$floatingDamage',
                  style: TextStyle(
                    fontSize: 46,
                    fontWeight: FontWeight.w900,
                    color: damageColor,
                    shadows: const [
                      Shadow(color: Colors.black, blurRadius: 12),
                    ],
                  ),
                ),
              ),
            ),

          // ==========================================
          // LAYER 2: TOP HUD & BOTTOM QUESTION PANEL
          // ==========================================
          Column(
            children: [
              // Top Bar HUD
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Pause Button
                      Container(
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.35), shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(Icons.pause_circle_filled_rounded, color: Colors.white, size: 34),
                          onPressed: widget.onExit,
                        ),
                      ),
                      // Boss Info & Red HP Bar
                      Column(
                        children: [
                          Row(
                            children: const [
                              Text(
                                'Lv.3 ',
                                style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.w900, fontSize: 13),
                              ),
                              Text(
                                'Rồng Lửa',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          GameHpBar(
                            currentHp: bossHp,
                            maxHp: maxBossHp,
                            barColor: AppColors.dangerRed,
                            width: 180,
                            height: 15,
                            label: '$bossHp / $maxBossHp',
                          ),
                        ],
                      ),
                      // Settings Icon
                      Container(
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.35), shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              // Player HP & Combo Row (Just above the question panel)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Player Panda HP Bar
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryGold,
                            shape: BoxShape.circle,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.asset(
                            'assets/images/characters/panda_avatar.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(child: Text('🐼', style: TextStyle(fontSize: 20))),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GameHpBar(
                          currentHp: playerHp,
                          maxHp: maxPlayerHp,
                          barColor: AppColors.successGreen,
                          width: 110,
                          height: 14,
                          label: '$playerHp / $maxPlayerHp',
                        ),
                      ],
                    ),

                    // Fiery Combo Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: AppColors.comboFlameGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF3D00).withOpacity(0.6),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            'Combo x$combo',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Question & Answer Panel
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: const BoxDecoration(
                  color: AppColors.cardCream,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, -4)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Feedback Banner
                    if (feedbackText != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        decoration: BoxDecoration(
                          color: feedbackText == 'Chính xác!' ? AppColors.successGreen : AppColors.dangerRed,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          feedbackText!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),

                    // Question Prompt
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.volume_up_rounded, color: AppColors.primaryBlue, size: 30),
                        SizedBox(width: 8),
                        Text(
                          '喝',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'hē\nHãy chọn đáp án đúng',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 12),

                    // 2x2 Answer Grid
                    Row(
                      children: [
                        AnswerButton(
                          text: 'uống',
                          state: selectedAnswerIndex == 0 ? AnswerButtonState.correct : AnswerButtonState.idle,
                          onTap: () => handleAnswer(0),
                        ),
                        const SizedBox(width: 10),
                        AnswerButton(
                          text: 'ăn',
                          state: selectedAnswerIndex == 1 ? AnswerButtonState.wrong : AnswerButtonState.idle,
                          onTap: () => handleAnswer(1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        AnswerButton(
                          text: 'cà phê',
                          state: selectedAnswerIndex == 2 ? AnswerButtonState.wrong : AnswerButtonState.idle,
                          onTap: () => handleAnswer(2),
                        ),
                        const SizedBox(width: 10),
                        AnswerButton(
                          text: 'sữa',
                          state: selectedAnswerIndex == 3 ? AnswerButtonState.wrong : AnswerButtonState.idle,
                          onTap: () => handleAnswer(3),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),

          // Red screen overlay flash when damaged
          if (isWrongAttack)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.red.withOpacity(0.24),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

