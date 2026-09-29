import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import 'animation/boss_battle_rive_contract.dart';
import 'controller/boss_battle_controller.dart';
import 'data/boss_battle_repository.dart';
import 'view/boss_battle_animated_character.dart';
import 'view/boss_battle_answer_button.dart';
import 'view/boss_battle_character_art.dart';
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
    return Obx(() {
      final phase = controller.phase.value;

      if (phase == BossBattlePhase.loading) {
        return const Scaffold(
          backgroundColor: Color(0xFF171018),
          body: SafeArea(
            child: _StatusOverlay(
              icon: Icons.hourglass_top_rounded,
              title: 'Đang triệu hồi Rồng Lửa',
              message: 'Đang tải câu hỏi trực tiếp từ Supabase...',
              showProgress: true,
            ),
          ),
        );
      }

      if (phase == BossBattlePhase.intro) {
        return Scaffold(
          backgroundColor: const Color(0xFF171018),
          body: SafeArea(
            child: _BossIntroScreen(controller: controller),
          ),
        );
      }

      return Scaffold(
        backgroundColor: const Color(0xFF140D13),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    flex: 59,
                    child: _BattleStage(controller: controller),
                  ),
                  Expanded(
                    flex: 41,
                    child: _QuestionPanel(controller: controller),
                  ),
                ],
              ),
              if (phase == BossBattlePhase.error)
                _ErrorOverlay(controller: controller),
              if (phase == BossBattlePhase.result)
                _ResultOverlay(controller: controller),
            ],
          ),
        ),
      );
    });
  }
}

class _BossIntroScreen extends StatelessWidget {
  const _BossIntroScreen({required this.controller});

  final BossBattleController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const CustomPaint(painter: _BattleBackdropPainter()),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x22000000),
                Color(0x33130C13),
                Color(0xEB130C13),
              ],
              stops: [0, .48, 1],
            ),
          ),
        ),
        Positioned(
          top: 12,
          left: 14,
          child: _RoundIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Get.back<void>(),
          ),
        ),
        Positioned(
          left: 18,
          right: 18,
          top: 36,
          child: Column(
            children: [
              const Text(
                'BOSS BATTLE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 39,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.2,
                  shadows: [
                    Shadow(
                      color: Color(0xAA7C1A18),
                      blurRadius: 14,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 9),
              Text(
                'Đánh bại Boss bằng kiến thức tiếng Trung!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .88),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 120,
          left: 12,
          right: 12,
          height: 300,
          child: Stack(
            children: [
              Align(
                alignment: const Alignment(-.88, .75),
                child: BossBattleAnimatedCharacter(
                  kind: BossBattleCharacterKind.panda,
                  motion: BossBattleCharacterMotion.ready,
                  size: 150,
                ),
              ),
              Align(
                alignment: const Alignment(.88, -.15),
                child: BossBattleAnimatedCharacter(
                  kind: BossBattleCharacterKind.dragon,
                  motion: BossBattleCharacterMotion.idle,
                  size: 205,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 18,
          right: 18,
          bottom: 22,
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 17, 18, 16),
            decoration: BoxDecoration(
              color: const Color(0xE8291B25),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: const Color(0x66FFD988),
                width: 1.2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x99000000),
                  blurRadius: 26,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                const _IntroFeature(
                  icon: Icons.psychology_alt_rounded,
                  title: 'Học từ vựng qua trận chiến',
                  subtitle: 'Câu hỏi thật lấy từ kho dữ liệu Supabase',
                ),
                const SizedBox(height: 11),
                const _IntroFeature(
                  icon: Icons.local_fire_department_rounded,
                  title: 'Càng đúng càng mạnh',
                  subtitle: 'Combo cao giúp đòn đánh gây nhiều sát thương hơn',
                ),
                const SizedBox(height: 11),
                const _IntroFeature(
                  icon: Icons.auto_awesome_rounded,
                  title: 'Phản hồi chiến đấu tức thì',
                  subtitle: 'Đúng thì bạn tấn công, sai thì Boss phản công',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA726),
                      foregroundColor: const Color(0xFF4D2400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                        side: const BorderSide(
                          color: Color(0xFFFFD46A),
                          width: 1.5,
                        ),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    onPressed: controller.beginBattle,
                    child: const Text('Bắt đầu chơi'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _IntroFeature extends StatelessWidget {
  const _IntroFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0x33FFCD67),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFFFFD166), size: 21),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .68),
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
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
                      onTap: () => Get.back<void>(),
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
                  kind: BossBattleCharacterKind.panda,
                  label: 'Học giả',
                  attacking: phase == BossBattlePhase.playerAttack,
                  hit: phase == BossBattlePhase.bossAttack,
                  victorious: phase == BossBattlePhase.won ||
                      phase == BossBattlePhase.reward ||
                      (phase == BossBattlePhase.result &&
                          controller.bossHp.value <= 0),
                  defeated: phase == BossBattlePhase.lost ||
                      (phase == BossBattlePhase.result &&
                          controller.playerHp.value <= 0),
                  lowHealth: controller.playerHp.value <= 30,
                  faceRight: true,
                ),
              ),
              Positioned(
                right: 18,
                top: 112,
                child: _BattleCharacter(
                  kind: BossBattleCharacterKind.dragon,
                  label: 'Boss',
                  attacking: phase == BossBattlePhase.bossAttack,
                  hit: phase == BossBattlePhase.playerAttack,
                  victorious: phase == BossBattlePhase.lost ||
                      (phase == BossBattlePhase.result &&
                          controller.playerHp.value <= 0),
                  defeated: phase == BossBattlePhase.won ||
                      phase == BossBattlePhase.reward ||
                      (phase == BossBattlePhase.result &&
                          controller.bossHp.value <= 0),
                  lowHealth: controller.bossHp.value <= 30,
                  faceRight: false,
                  boss: true,
                ),
              ),
              if (phase == BossBattlePhase.playerAttack &&
                  controller.lastBossDamage.value > 0)
                Positioned(
                  right: 38,
                  top: 210,
                  child: _DamagePopup(
                    amount: controller.lastBossDamage.value,
                    color: const Color(0xFFFFD34E),
                  ),
                ),
              if (phase == BossBattlePhase.bossAttack &&
                  controller.lastPlayerDamage.value > 0)
                Positioned(
                  left: 48,
                  bottom: 170,
                  child: _DamagePopup(
                    amount: controller.lastPlayerDamage.value,
                    color: const Color(0xFFFF6666),
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
          color: Color(0xFFFFF8ED),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final canAnswer = controller.canAnswer;
      final result = controller.lastAnswerCorrect.value;

      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFBF4), Color(0xFFFFF3E3)],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 26,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8C9B8),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _BattlePill(
                    icon: Icons.quiz_rounded,
                    label:
                        'Câu ${controller.questionNumber}/${controller.questions.length}',
                    color: AppColors.redDark,
                  ),
                  const Spacer(),
                  _BattlePill(
                    icon: Icons.local_fire_department_rounded,
                    label: 'Combo x${controller.combo.value}',
                    color: const Color(0xFFD98218),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'CHỌN ĐÁP ÁN ĐÚNG',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF9B7651),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
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
                  fontSize: 28,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: result == null
                    ? _PhaseHint(
                        key: ValueKey(controller.phase.value),
                        text: controller.phaseHint,
                        active: canAnswer,
                      )
                    : _AnswerFeedback(
                        key: ValueKey(
                          '${controller.currentIndex.value}_$result',
                        ),
                        correct: result,
                        text: controller.feedbackText,
                      ),
              ),
              const SizedBox(height: 10),
              IgnorePointer(
                ignoring: !canAnswer,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: question.answers.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.92,
                  ),
                  itemBuilder: (context, index) {
                    final answer = question.answers[index];
                    return BossBattleAnswerButton(
                      answer: answer,
                      index: index,
                      state: _answerState(answer, question.correctAnswer),
                      onTap: canAnswer
                          ? () {
                              controller.answer(answer);
                            }
                          : null,
                    );
                  },
                ),
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
      return controller.canAnswer
          ? BossBattleAnswerVisualState.idle
          : BossBattleAnswerVisualState.disabled;
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

class _BattlePill extends StatelessWidget {
  const _BattlePill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: .15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhaseHint extends StatelessWidget {
  const _PhaseHint({
    super.key,
    required this.text,
    required this.active,
  });

  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 34),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFFFEFCF)
            : const Color(0xFFF2EAE0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text.isEmpty ? 'Chuẩn bị...' : text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: active ? const Color(0xFF8A5A15) : AppColors.muted,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _AnswerFeedback extends StatelessWidget {
  const _AnswerFeedback({
    super.key,
    required this.correct,
    required this.text,
  });

  final bool correct;
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = correct ? AppColors.success : AppColors.error;
    return Container(
      constraints: const BoxConstraints(minHeight: 34),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: .18)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            correct ? Icons.bolt_rounded : Icons.info_outline_rounded,
            color: color,
            size: 17,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _BattleCharacter extends StatelessWidget {
  const _BattleCharacter({
    required this.kind,
    required this.label,
    required this.attacking,
    required this.hit,
    required this.victorious,
    required this.defeated,
    required this.lowHealth,
    required this.faceRight,
    this.boss = false,
  });

  final BossBattleCharacterKind kind;
  final String label;
  final bool attacking;
  final bool hit;
  final bool victorious;
  final bool defeated;
  final bool lowHealth;
  final bool faceRight;
  final bool boss;

  @override
  Widget build(BuildContext context) {
    final shift = attacking ? (faceRight ? 18.0 : -18.0) : 0.0;
    final artSize = boss ? 136.0 : 112.0;
    final motion = defeated
        ? BossBattleCharacterMotion.defeat
        : victorious
            ? BossBattleCharacterMotion.victory
            : attacking
                ? BossBattleCharacterMotion.attack
                : hit
                    ? BossBattleCharacterMotion.hit
                    : lowHealth
                        ? BossBattleCharacterMotion.lowHp
                        : BossBattleCharacterMotion.idle;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 260),
      opacity: defeated ? .45 : 1,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutBack,
        scale: attacking ? 1.12 : (hit ? .94 : (defeated ? .86 : 1)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          transform: Matrix4.translationValues(shift, 0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    bottom: 4,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: boss ? 116 : 92,
                      height: boss ? 30 : 24,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99),
                        gradient: RadialGradient(
                          colors: hit
                              ? const [
                                  Color(0x99FF4747),
                                  Color(0x33FF4747),
                                  Color(0x00000000),
                                ]
                              : const [
                                  Color(0x66000000),
                                  Color(0x33000000),
                                  Color(0x00000000),
                                ],
                        ),
                      ),
                    ),
                  ),
                  if (attacking)
                    Positioned(
                      bottom: 18,
                      child: Container(
                        width: boss ? 138 : 112,
                        height: boss ? 138 : 112,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Color(0x55FFD35A),
                              Color(0x11FFD35A),
                              Color(0x00FFD35A),
                            ],
                          ),
                        ),
                      ),
                    ),
                  BossBattleAnimatedCharacter(
                    kind: kind,
                    motion: motion,
                    size: artSize,
                    defeated: defeated,
                  ),
                ],
              ),
              Transform.translate(
                offset: const Offset(0, -4),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xB3181115),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: const Color(0x55FFE2A5)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x44000000),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .3,
                    ),
                  ),
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

class _DamagePopup extends StatelessWidget {
  const _DamagePopup({
    required this.amount,
    required this.color,
  });

  final int amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('$amount-${color.value}'),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Transform.translate(
        offset: Offset(0, -20 * value),
        child: Opacity(
          opacity: (1 - (value * .35)).clamp(0.0, 1.0),
          child: child,
        ),
      ),
      child: Text(
        '-$amount',
        style: TextStyle(
          color: color,
          fontSize: 26,
          fontWeight: FontWeight.w900,
          shadows: const [
            Shadow(color: Color(0xCC000000), blurRadius: 8, offset: Offset(0, 2)),
          ],
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
                      onPressed: () => Get.back<void>(),
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
      color: const Color(0xD911080E),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(22),
          constraints: const BoxConstraints(maxWidth: 430),
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
          decoration: BoxDecoration(
            gradient: won
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFFF1B7), Color(0xFFFFF9EA)],
                  )
                : const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF3A151D), Color(0xFF1C1117)],
                  ),
            borderRadius: BorderRadius.circular(29),
            border: Border.all(
              color: won ? const Color(0xFFFFC84B) : const Color(0xFFB64A55),
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x99000000),
                blurRadius: 36,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                won ? Icons.emoji_events_rounded : Icons.heart_broken_rounded,
                color: won ? const Color(0xFFFFB300) : const Color(0xFFFF7A7A),
                size: 65,
              ),
              const SizedBox(height: 8),
              Text(
                won ? 'Chiến thắng!' : 'Thất bại!',
                style: TextStyle(
                  color: won ? AppColors.redDark : Colors.white,
                  fontSize: 31,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                won
                    ? 'Rồng Lửa đã bị đánh bại. Kiến thức của bạn mạnh hơn!'
                    : 'Đừng bỏ cuộc! Luyện thêm rồi quay lại phục thù nhé.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: won
                      ? AppColors.muted
                      : Colors.white.withValues(alpha: .72),
                  height: 1.4,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),
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
                      label: 'Combo',
                      value: 'x${controller.maxCombo.value}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 19),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            won ? AppColors.ink : const Color(0xFFFFD7D7),
                        side: BorderSide(
                          color: won
                              ? const Color(0xFFD8C9B8)
                              : const Color(0xFF6F3A43),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Get.back<void>(),
                      child: const Text('Về Game Hub'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: won
                            ? const Color(0xFF29C76F)
                            : const Color(0xFFFFA12B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: controller.startBattle,
                      child: Text(won ? 'Tiếp tục' : 'Thử lại'),
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
          Color(0xFF4DB8E6),
          Color(0xFF9EDCE6),
          Color(0xFFF7C7B0),
        ],
        stops: [0, .52, 1],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, skyPaint);

    final sunPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFFFFF0B0),
          Color(0x99FFD56A),
          Color(0x00FFD56A),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * .79, size.height * .16),
          radius: size.width * .18,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * .79, size.height * .16),
      size.width * .18,
      sunPaint,
    );

    _paintCloud(
      canvas,
      Offset(size.width * .18, size.height * .20),
      size.width * .16,
      const Color(0xB3FFFFFF),
    );
    _paintCloud(
      canvas,
      Offset(size.width * .63, size.height * .29),
      size.width * .13,
      const Color(0x8FFFFFFF),
    );

    final farMountain = Paint()..color = const Color(0xFF789CA3);
    final farPath = Path()
      ..moveTo(0, size.height * .60)
      ..lineTo(size.width * .12, size.height * .27)
      ..lineTo(size.width * .25, size.height * .53)
      ..lineTo(size.width * .41, size.height * .20)
      ..lineTo(size.width * .56, size.height * .55)
      ..lineTo(size.width * .76, size.height * .25)
      ..lineTo(size.width, size.height * .58)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(farPath, farMountain);

    final mistPaint = Paint()..color = const Color(0x52FFFFFF);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * .51, size.height * .56),
        width: size.width * .95,
        height: size.height * .16,
      ),
      mistPaint,
    );

    final nearMountain = Paint()..color = const Color(0xFF436D61);
    final nearPath = Path()
      ..moveTo(0, size.height * .75)
      ..lineTo(size.width * .18, size.height * .48)
      ..lineTo(size.width * .33, size.height * .70)
      ..lineTo(size.width * .50, size.height * .44)
      ..lineTo(size.width * .65, size.height * .71)
      ..lineTo(size.width * .83, size.height * .48)
      ..lineTo(size.width, size.height * .69)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(nearPath, nearMountain);

    final templePaint = Paint()..color = const Color(0xFF9B3E34);
    final roofPaint = Paint()..color = const Color(0xFF2B3237);
    final roofEdge = Paint()
      ..color = const Color(0xFFE4B953)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final x in <double>[.14, .48, .82]) {
      final cx = size.width * x;
      final baseY = size.height * (.50 + ((x * 10).round().isEven ? .03 : 0));
      final templeRect = Rect.fromCenter(
        center: Offset(cx, baseY),
        width: size.width * .08,
        height: size.height * .11,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(templeRect, const Radius.circular(3)),
        templePaint,
      );

      final roof = Path()
        ..moveTo(cx - size.width * .058, baseY - size.height * .061)
        ..quadraticBezierTo(
          cx - size.width * .020,
          baseY - size.height * .105,
          cx,
          baseY - size.height * .108,
        )
        ..quadraticBezierTo(
          cx + size.width * .020,
          baseY - size.height * .105,
          cx + size.width * .058,
          baseY - size.height * .061,
        )
        ..quadraticBezierTo(
          cx,
          baseY - size.height * .074,
          cx - size.width * .058,
          baseY - size.height * .061,
        )
        ..close();
      canvas.drawPath(roof, roofPaint);
      canvas.drawPath(roof, roofEdge);
    }

    final arenaShadow = Paint()..color = const Color(0x55000000);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * .50, size.height * .82),
        width: size.width * .78,
        height: size.height * .12,
      ),
      arenaShadow,
    );

    final arenaPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFE4C48F),
          Color(0xFFB77D4C),
        ],
      ).createShader(
        Rect.fromLTWH(
          size.width * .08,
          size.height * .73,
          size.width * .84,
          size.height * .17,
        ),
      );
    final arenaRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * .08,
        size.height * .74,
        size.width * .84,
        size.height * .13,
      ),
      const Radius.circular(22),
    );
    canvas.drawRRect(arenaRect, arenaPaint);

    final arenaLine = Paint()
      ..color = const Color(0x99FFE7B1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(arenaRect, arenaLine);

    final blossom = Paint()..color = const Color(0xFFFFA8C5);
    final blossomDark = Paint()..color = const Color(0xFFE66E9A);
    final points = <Offset>[
      Offset(size.width * .08, size.height * .18),
      Offset(size.width * .18, size.height * .34),
      Offset(size.width * .31, size.height * .13),
      Offset(size.width * .58, size.height * .16),
      Offset(size.width * .71, size.height * .31),
      Offset(size.width * .90, size.height * .20),
      Offset(size.width * .84, size.height * .46),
      Offset(size.width * .13, size.height * .58),
      Offset(size.width * .90, size.height * .60),
    ];
    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      canvas.drawCircle(point, i.isEven ? 3.8 : 3.0, blossom);
      canvas.drawCircle(point.translate(2.2, -1.7), 1.4, blossomDark);
    }

    _paintLantern(
      canvas,
      Offset(size.width * .055, size.height * .43),
      size.width * .035,
    );
    _paintLantern(
      canvas,
      Offset(size.width * .945, size.height * .39),
      size.width * .035,
    );
  }

  void _paintCloud(
    Canvas canvas,
    Offset center,
    double width,
    Color color,
  ) {
    final paint = Paint()..color = color;
    final h = width * .32;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: width, height: h),
      paint,
    );
    canvas.drawCircle(
      center.translate(-width * .22, -h * .20),
      h * .42,
      paint,
    );
    canvas.drawCircle(
      center.translate(width * .02, -h * .32),
      h * .55,
      paint,
    );
    canvas.drawCircle(
      center.translate(width * .25, -h * .14),
      h * .38,
      paint,
    );
  }

  void _paintLantern(Canvas canvas, Offset center, double radius) {
    final glow = Paint()
      ..shader = RadialGradient(
        colors: const [
          Color(0x99FFD56C),
          Color(0x33FF8F3A),
          Color(0x00FF8F3A),
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius * 2.5),
      );
    canvas.drawCircle(center, radius * 2.5, glow);

    final red = Paint()..color = const Color(0xFFE04E3D);
    final gold = Paint()..color = const Color(0xFFF4C867);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: radius * 1.55,
          height: radius * 2.05,
        ),
        Radius.circular(radius * .35),
      ),
      red,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: center.translate(0, -radius * 1.08),
        width: radius * 1.18,
        height: radius * .18,
      ),
      gold,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: center.translate(0, radius * 1.08),
        width: radius * 1.18,
        height: radius * .18,
      ),
      gold,
    );
  }

  @override
  bool shouldRepaint(covariant _BattleBackdropPainter oldDelegate) => false;
}
