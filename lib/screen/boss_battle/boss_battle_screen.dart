import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import 'controller/boss_battle_controller.dart';
import 'data/boss_battle_repository.dart';
import 'view/boss_battle_answer_button.dart';
import 'view/boss_battle_health_bar.dart';

class BossBattleScreen extends StatefulWidget {
  const BossBattleScreen({super.key});

  @override
  State<BossBattleScreen> createState() => _BossBattleScreenState();
}

class _BossBattleScreenState extends State<BossBattleScreen> {
  late final String _controllerTag;
  late final BossBattleController controller;

  @override
  void initState() {
    super.initState();
    _controllerTag = 'boss_battle_${identityHashCode(this)}';
    controller = Get.put(
      BossBattleController(source: BossBattleRepository()),
      tag: _controllerTag,
    );
  }

  @override
  void dispose() {
    Get.delete<BossBattleController>(tag: _controllerTag, force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF140D13),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  flex: 56,
                  child: _BattleStage(controller: controller),
                ),
                Expanded(
                  flex: 44,
                  child: _QuestionPanel(controller: controller),
                ),
              ],
            ),
            Obx(() {
              switch (controller.phase.value) {
                case BossBattlePhase.loading:
                  return const _StatusOverlay(
                    icon: Icons.hourglass_top_rounded,
                    title: 'Đang chuẩn bị chiến trường',
                    message:
                        'Lần mở đầu có thể mất vài giây để chuẩn bị kho câu hỏi ngoại tuyến.',
                    showProgress: true,
                  );
                case BossBattlePhase.intro:
                  return const _StatusOverlay(
                    icon: Icons.local_fire_department_rounded,
                    title: 'Boss xuất hiện!',
                    message: 'Trả lời đúng để tung đòn và hạ Rồng Hỏa.',
                  );
                case BossBattlePhase.error:
                  return _ErrorOverlay(controller: controller);
                case BossBattlePhase.result:
                  return _ResultOverlay(controller: controller);
                default:
                  return const SizedBox.shrink();
              }
            }),
          ],
        ),
      ),
    );
  }
}

class _BattleStage extends StatelessWidget {
  const _BattleStage({required this.controller});

  final BossBattleController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final phase = controller.phase.value;
      final isImpact = phase == BossBattlePhase.playerAttack ||
          phase == BossBattlePhase.bossAttack;

      return TweenAnimationBuilder<double>(
        key: ValueKey('stage_${phase.name}_${controller.currentIndex.value}'),
        tween: Tween<double>(begin: 0, end: isImpact ? 1 : 0),
        duration: const Duration(milliseconds: 420),
        builder: (context, value, child) {
          final shake = isImpact
              ? math.sin(value * math.pi * 8) * (1 - value) * 5
              : 0.0;
          return Transform.translate(
            offset: Offset(shake, 0),
            child: child,
          );
        },
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              const CustomPaint(painter: _BattleBackdropPainter()),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        const Color(0xFF140D13).withValues(alpha: .12),
                        const Color(0xFF140D13).withValues(alpha: .72),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                top: 10,
                child: Row(
                  children: [
                    _RoundIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: Get.back,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BOSS BATTLE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .8,
                            ),
                          ),
                          Text(
                            'Rồng Hỏa • 火龙',
                            style: TextStyle(
                              color: Color(0xFFD7C7C6),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _ScoreChip(score: controller.score.value),
                  ],
                ),
              ),
              Positioned(
                top: 68,
                left: 42,
                right: 42,
                child: BossBattleHealthBar(
                  label: 'Rồng Hỏa',
                  current: controller.bossHp.value,
                  max: BossBattleController.maxBossHp,
                  color: const Color(0xFFE84545),
                  icon: Icons.whatshot_rounded,
                ),
              ),
              Positioned(
                left: 22,
                bottom: 72,
                child: _BattleCharacter(
                  emoji: '🐼',
                  label: 'Học giả',
                  attacking: phase == BossBattlePhase.playerAttack,
                  defeated: phase == BossBattlePhase.lost,
                  faceRight: true,
                ),
              ),
              Positioned(
                right: 18,
                top: 112,
                child: _BattleCharacter(
                  emoji: '🐉',
                  label: 'Boss',
                  attacking: phase == BossBattlePhase.bossAttack,
                  defeated: phase == BossBattlePhase.won ||
                      phase == BossBattlePhase.reward ||
                      (phase == BossBattlePhase.result &&
                          controller.bossHp.value <= 0),
                  faceRight: false,
                  boss: true,
                ),
              ),
              if (controller.combo.value >= 2)
                Positioned(
                  left: 18,
                  top: 118,
                  child: _ComboBadge(combo: controller.combo.value),
                ),
              _ProjectileFx(
                phase: phase,
                questionIndex: controller.currentIndex.value,
                duration: controller.attackDelay,
              ),
              Positioned(
                left: 28,
                right: 28,
                bottom: 18,
                child: BossBattleHealthBar(
                  label: 'Sinh lực',
                  current: controller.playerHp.value,
                  max: BossBattleController.maxPlayerHp,
                  color: const Color(0xFF49C66B),
                  icon: Icons.favorite_rounded,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _QuestionPanel extends StatelessWidget {
  const _QuestionPanel({required this.controller});

  final BossBattleController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final question = controller.currentQuestion;
      if (question == null) {
        return const ColoredBox(
          color: Color(0xFFFFF7EA),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      return Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFF7EA),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Color(0x55000000),
              blurRadius: 22,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      'Câu ${controller.questionNumber}/${controller.questions.length}',
                      style: const TextStyle(
                        color: AppColors.redDark,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFFE6A52A),
                    size: 18,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Combo x${controller.combo.value}',
                    style: const TextStyle(
                      color: Color(0xFF73551E),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Chọn chữ Hán đúng',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                question.prompt,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 25,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: controller.lastAnswerCorrect.value == null
                    ? const SizedBox(height: 22)
                    : Text(
                        controller.feedbackText,
                        key: ValueKey(controller.feedbackText),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: controller.lastAnswerCorrect.value == true
                              ? AppColors.success
                              : AppColors.error,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: question.answers.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.15,
                ),
                itemBuilder: (context, index) {
                  final answer = question.answers[index];
                  return BossBattleAnswerButton(
                    answer: answer,
                    state: _answerState(answer, question.correctAnswer),
                    onTap: controller.isInputLocked.value
                        ? null
                        : () => controller.answer(answer),
                  );
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      icon: Icons.stars_rounded,
                      label: 'Điểm',
                      value: '${controller.score.value}',
                      color: const Color(0xFFE5A22A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MiniStat(
                      icon: Icons.check_circle_rounded,
                      label: 'Đúng',
                      value: '${controller.correctCount.value}',
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MiniStat(
                      icon: Icons.close_rounded,
                      label: 'Sai',
                      value: '${controller.wrongCount.value}',
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  BossBattleAnswerVisualState _answerState(
    String answer,
    String correctAnswer,
  ) {
    final result = controller.lastAnswerCorrect.value;
    final selected = controller.selectedAnswer.value;

    if (result == null) {
      return controller.isInputLocked.value
          ? BossBattleAnswerVisualState.disabled
          : BossBattleAnswerVisualState.idle;
    }

    if (answer == correctAnswer) {
      return BossBattleAnswerVisualState.correct;
    }

    if (answer == selected && result == false) {
      return BossBattleAnswerVisualState.wrong;
    }

    return BossBattleAnswerVisualState.disabled;
  }
}

class _BattleCharacter extends StatelessWidget {
  const _BattleCharacter({
    required this.emoji,
    required this.label,
    required this.attacking,
    required this.defeated,
    required this.faceRight,
    this.boss = false,
  });

  final String emoji;
  final String label;
  final bool attacking;
  final bool defeated;
  final bool faceRight;
  final bool boss;

  @override
  Widget build(BuildContext context) {
    final shift = attacking ? (faceRight ? 14.0 : -14.0) : 0.0;
    final size = boss ? 92.0 : 78.0;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 280),
      opacity: defeated ? .38 : 1,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: attacking ? 1.13 : (defeated ? .88 : 1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.translationValues(shift, 0, 0),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xC8191116),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: TextStyle(fontSize: size)),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectileFx extends StatelessWidget {
  const _ProjectileFx({
    required this.phase,
    required this.questionIndex,
    required this.duration,
  });

  final BossBattlePhase phase;
  final int questionIndex;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final playerAttack = phase == BossBattlePhase.playerAttack;
    final bossAttack = phase == BossBattlePhase.bossAttack;
    if (!playerAttack && !bossAttack) return const SizedBox.shrink();

    return Positioned.fill(
      child: IgnorePointer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final from = playerAttack
                ? Offset(constraints.maxWidth * .28, constraints.maxHeight * .67)
                : Offset(constraints.maxWidth * .72, constraints.maxHeight * .38);
            final to = playerAttack
                ? Offset(constraints.maxWidth * .72, constraints.maxHeight * .38)
                : Offset(constraints.maxWidth * .28, constraints.maxHeight * .67);
            final color = playerAttack
                ? const Color(0xFFFFC43D)
                : const Color(0xFFFF4E62);

            return TweenAnimationBuilder<double>(
              key: ValueKey('${phase.name}_$questionIndex'),
              tween: Tween<double>(begin: 0, end: 1),
              duration: duration,
              curve: Curves.easeInOutCubic,
              builder: (context, value, _) {
                final x = from.dx + ((to.dx - from.dx) * value);
                final y = from.dy + ((to.dy - from.dy) * value);
                final pulse = 18 + (math.sin(value * math.pi) * 14);
                return Stack(
                  children: [
                    Positioned(
                      left: x - pulse / 2,
                      top: y - pulse / 2,
                      child: Container(
                        width: pulse,
                        height: pulse,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: .75),
                              blurRadius: 26,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ComboBadge extends StatelessWidget {
  const _ComboBadge({required this.combo});

  final int combo;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -.08,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD43A), Color(0xFFFF6A2D)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(color: Color(0x66FF8D2E), blurRadius: 16),
          ],
        ),
        child: Text(
          'COMBO x$combo',
          style: const TextStyle(
            color: Color(0xFF5B1B0F),
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xCC20171C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars_rounded, color: Color(0xFFFFD85A), size: 17),
          const SizedBox(width: 5),
          Text(
            '$score',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xCC20171C),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              '$label $value',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusOverlay extends StatelessWidget {
  const _StatusOverlay({
    required this.icon,
    required this.title,
    required this.message,
    this.showProgress = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xB30B070A),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(28),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF6E9),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFE8B65B), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.red, size: 52),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.muted,
                  height: 1.45,
                ),
              ),
              if (showProgress) ...[
                const SizedBox(height: 18),
                const CircularProgressIndicator(color: AppColors.red),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorOverlay extends StatelessWidget {
  const _ErrorOverlay({required this.controller});

  final BossBattleController controller;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xD10B070A),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(28),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 52),
              const SizedBox(height: 12),
              const Text(
                'Không thể bắt đầu trận đấu',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, height: 1.4),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: Get.back,
                      child: const Text('Quay lại'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: controller.startBattle,
                      child: const Text('Thử lại'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultOverlay extends StatelessWidget {
  const _ResultOverlay({required this.controller});

  final BossBattleController controller;

  @override
  Widget build(BuildContext context) {
    final won = controller.bossHp.value < controller.playerHp.value;

    return ColoredBox(
      color: const Color(0xCC0B070A),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 430),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7EA),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: won ? const Color(0xFFE8B64E) : const Color(0xFFCF6D6D),
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(color: Color(0x66000000), blurRadius: 28),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(won ? '🏆' : '🔥', style: const TextStyle(fontSize: 62)),
              const SizedBox(height: 8),
              Text(
                won ? 'Chiến thắng!' : 'Thử lại nhé!',
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                won
                    ? 'Bạn đã đánh bại Rồng Hỏa bằng kiến thức tiếng Trung.'
                    : 'Ôn lại vài từ khó rồi quay lại phục thù boss.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, height: 1.45),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _ResultStat(
                      label: 'Điểm',
                      value: '${controller.score.value}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ResultStat(
                      label: 'Đúng',
                      value: '${controller.correctCount.value}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ResultStat(
                      label: 'Max combo',
                      value: 'x${controller.maxCombo.value}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Điểm trận hiện chỉ là feedback gameplay. XP/Coins chưa được tự cộng ở client.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: Get.back,
                      icon: const Icon(Icons.grid_view_rounded),
                      label: const Text('Kho game'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: controller.startBattle,
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('Chơi lại'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  const _ResultStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.redDark,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BattleBackdropPainter extends CustomPainter {
  const _BattleBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF63C7F2),
          Color(0xFFA8E0EA),
          Color(0xFFF4C6B0),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, skyPaint);

    final farMountain = Paint()..color = const Color(0xFF73959B);
    final nearMountain = Paint()..color = const Color(0xFF466F66);

    final farPath = Path()
      ..moveTo(0, size.height * .58)
      ..lineTo(size.width * .14, size.height * .25)
      ..lineTo(size.width * .27, size.height * .52)
      ..lineTo(size.width * .43, size.height * .20)
      ..lineTo(size.width * .58, size.height * .55)
      ..lineTo(size.width * .76, size.height * .24)
      ..lineTo(size.width, size.height * .58)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(farPath, farMountain);

    final nearPath = Path()
      ..moveTo(0, size.height * .72)
      ..lineTo(size.width * .18, size.height * .47)
      ..lineTo(size.width * .34, size.height * .69)
      ..lineTo(size.width * .50, size.height * .43)
      ..lineTo(size.width * .64, size.height * .70)
      ..lineTo(size.width * .82, size.height * .48)
      ..lineTo(size.width, size.height * .68)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(nearPath, nearMountain);

    final templePaint = Paint()..color = const Color(0xFF8C322B);
    final roofPaint = Paint()..color = const Color(0xFF2F3438);

    for (final x in <double>[.15, .48, .80]) {
      final cx = size.width * x;
      final baseY = size.height * (.50 + ((x * 10).round().isEven ? .03 : 0));
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(cx, baseY),
          width: size.width * .08,
          height: size.height * .11,
        ),
        templePaint,
      );
      final roof = Path()
        ..moveTo(cx - size.width * .055, baseY - size.height * .065)
        ..lineTo(cx, baseY - size.height * .11)
        ..lineTo(cx + size.width * .055, baseY - size.height * .065)
        ..close();
      canvas.drawPath(roof, roofPaint);
    }

    final blossom = Paint()..color = const Color(0xFFFFA9C7);
    final points = <Offset>[
      Offset(size.width * .08, size.height * .18),
      Offset(size.width * .18, size.height * .34),
      Offset(size.width * .31, size.height * .13),
      Offset(size.width * .58, size.height * .16),
      Offset(size.width * .71, size.height * .31),
      Offset(size.width * .90, size.height * .20),
      Offset(size.width * .84, size.height * .46),
    ];
    for (final point in points) {
      canvas.drawCircle(point, 3.5, blossom);
    }
  }

  @override
  bool shouldRepaint(covariant _BattleBackdropPainter oldDelegate) => false;
}
