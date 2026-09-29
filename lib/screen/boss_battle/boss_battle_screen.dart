import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
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
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _controllerTag = 'boss_battle_${identityHashCode(this)}';
    controller = Get.put(
      BossBattleController(source: BossBattleRepository()),
      tag: _controllerTag,
    );
    _configureTts();
  }

  Future<void> _configureTts() async {
    try {
      await _tts.setLanguage('zh-CN');
      await _tts.setSpeechRate(0.42);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
    } catch (_) {}
  }

  Future<void> _speakCurrentPrompt() async {
    final text = controller.currentQuestion?.prompt.trim() ?? '';
    if (text.isEmpty) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {
      Get.snackbar(
        'Không phát được âm thanh',
        'Thiết bị chưa có giọng đọc tiếng Trung.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void dispose() {
    _tts.stop();
    Get.delete<BossBattleController>(tag: _controllerTag, force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final phase = controller.phase.value;

      if (phase == BossBattlePhase.loading) {
        return const Scaffold(
          backgroundColor: Color(0xFF170F17),
          body: SafeArea(
            child: _CenteredStatus(
              icon: Icons.local_fire_department_rounded,
              title: 'Đang triệu hồi Rồng Lửa',
              message: 'Đang tải câu hỏi trực tiếp từ Supabase...',
              loading: true,
            ),
          ),
        );
      }

      if (phase == BossBattlePhase.intro) {
        return Scaffold(
          backgroundColor: const Color(0xFF170F17),
          body: SafeArea(
            child: _BossIntro(controller: controller),
          ),
        );
      }

      return Scaffold(
        backgroundColor: const Color(0xFF170F17),
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              _GameplayScene(
                controller: controller,
                onSpeakPrompt: _speakCurrentPrompt,
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

class _BossIntro extends StatelessWidget {
  const _BossIntro({required this.controller});

  final BossBattleController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const CustomPaint(painter: _ArenaPainter(intro: true)),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x10000000),
                Color(0x22120B12),
                Color(0xEA120B12),
              ],
              stops: [0, .54, 1],
            ),
          ),
        ),
        Positioned(
          top: 12,
          left: 14,
          child: _CircleAction(
            icon: Icons.arrow_back_rounded,
            onTap: () => Get.back<void>(),
          ),
        ),
        Positioned(
          left: 18,
          right: 18,
          top: 38,
          child: Column(
            children: [
              const Text(
                'BOSS BATTLE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFFE2A1),
                  fontSize: 38,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.1,
                  shadows: [
                    Shadow(
                      color: Color(0xFF8E2019),
                      blurRadius: 4,
                      offset: Offset(0, 3),
                    ),
                    Shadow(
                      color: Color(0xAA000000),
                      blurRadius: 14,
                      offset: Offset(0, 7),
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
          top: 105,
          left: 0,
          right: 0,
          height: 330,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Align(
                alignment: const Alignment(-.76, .78),
                child: BossBattleAnimatedCharacter(
                  kind: BossBattleCharacterKind.panda,
                  motion: BossBattleCharacterMotion.ready,
                  size: 150,
                ),
              ),
              Align(
                alignment: const Alignment(.78, -.2),
                child: BossBattleAnimatedCharacter(
                  kind: BossBattleCharacterKind.dragon,
                  flipX: true,
                  motion: BossBattleCharacterMotion.idle,
                  size: 218,
                ),
              ),
              Align(
                alignment: const Alignment(.05, .2),
                child: Transform.rotate(
                  angle: -.22,
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    color: Color(0xFFFFB32C),
                    size: 54,
                    shadows: [
                      Shadow(color: Color(0xFFFF4B21), blurRadius: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 18,
          right: 18,
          bottom: 18,
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 17, 18, 16),
            decoration: BoxDecoration(
              color: const Color(0xE82A1B25),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: const Color(0x66FFD989),
                width: 1.2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x99000000),
                  blurRadius: 28,
                  offset: Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              children: [
                const _IntroLine(
                  icon: Icons.menu_book_rounded,
                  title: 'Học từ vựng qua trận chiến',
                ),
                const SizedBox(height: 11),
                const _IntroLine(
                  icon: Icons.sports_martial_arts_rounded,
                  title: 'Càng đúng càng mạnh',
                ),
                const SizedBox(height: 11),
                const _IntroLine(
                  icon: Icons.auto_awesome_rounded,
                  title: 'Phản hồi chiến đấu tức thì',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA321),
                      foregroundColor: const Color(0xFF4B2300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                        side: const BorderSide(
                          color: Color(0xFFFFD668),
                          width: 1.5,
                        ),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    onPressed: controller.beginBattle,
                    icon: const Icon(Icons.swords_rounded),
                    label: const Text('Bắt đầu chơi'),
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

class _IntroLine extends StatelessWidget {
  const _IntroLine({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0x33FFD36D),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFFFFD166), size: 21),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _GameplayScene extends StatelessWidget {
  const _GameplayScene({
    required this.controller,
    required this.onSpeakPrompt,
  });

  final BossBattleController controller;
  final VoidCallback onSpeakPrompt;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final question = controller.currentQuestion;
      final phase = controller.phase.value;
      final isImpact = phase == BossBattlePhase.playerAttack ||
          phase == BossBattlePhase.bossAttack;

      if (question == null) {
        return const _CenteredStatus(
          icon: Icons.hourglass_top_rounded,
          title: 'Đang chuẩn bị câu hỏi',
          message: 'Một chút nữa thôi...',
          loading: true,
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          final h = constraints.maxHeight;
          final compact = h < 700;

          return TweenAnimationBuilder<double>(
            key: ValueKey(
              'battle_${phase.name}_${controller.currentIndex.value}',
            ),
            tween: Tween(begin: 0, end: isImpact ? 1 : 0),
            duration: const Duration(milliseconds: 440),
            builder: (context, value, child) {
              final shake = isImpact
                  ? math.sin(value * math.pi * 8) * (1 - value) * 5.5
                  : 0.0;
              return Transform.translate(
                offset: Offset(shake, 0),
                child: child,
              );
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                const CustomPaint(painter: _ArenaPainter()),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x08000000),
                        Color(0x00000000),
                        Color(0x50120B12),
                        Color(0xD9120B12),
                      ],
                      stops: [0, .43, .73, 1],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 12,
                  child: _CircleAction(
                    icon: Icons.pause_rounded,
                    onTap: () => Get.back<void>(),
                  ),
                ),
                const Positioned(
                  top: 12,
                  right: 12,
                  child: _CircleAction(
                    icon: Icons.settings_rounded,
                    onTap: null,
                  ),
                ),
                Positioned(
                  top: 11,
                  left: 66,
                  right: 66,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xCC4B2115),
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(
                                color: const Color(0x88FFD16B),
                              ),
                            ),
                            child: const Text(
                              'Lv.3',
                              style: TextStyle(
                                color: Color(0xFFFFD974),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 7),
                          const Text(
                            'Rồng Lửa',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              shadows: [
                                Shadow(color: Colors.black54, blurRadius: 5),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      BossBattleHealthBar(
                        label: '',
                        current: controller.bossHp.value,
                        max: BossBattleController.maxBossHp,
                        color: const Color(0xFFF23538),
                        icon: Icons.local_fire_department_rounded,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: compact ? 76 : 86,
                  right: -4,
                  child: BossBattleAnimatedCharacter(
                    kind: BossBattleCharacterKind.dragon,
                    motion: _dragonMotion(controller),
                    size: compact ? 160 : 190,
                    defeated: controller.bossHp.value <= 0,
                  ),
                ),
                Positioned(
                  top: compact ? 158 : 180,
                  left: 4,
                  child: BossBattleAnimatedCharacter(
                    kind: BossBattleCharacterKind.panda,
                    motion: _pandaMotion(controller),
                    size: compact ? 103 : 118,
                    defeated: controller.playerHp.value <= 0,
                  ),
                ),
                _BattleAttackFx(
                  phase: phase,
                  index: controller.currentIndex.value,
                  duration: controller.attackDelay,
                ),
                if (phase == BossBattlePhase.playerAttack)
                  const Positioned(
                    left: 26,
                    right: 26,
                    bottom: 178,
                    child: _CombatFeedbackBanner(
                      text: 'Chính xác!',
                      color: Color(0xFF21C96B),
                      icon: Icons.check_circle_rounded,
                    ),
                  ),
                if (phase == BossBattlePhase.bossAttack)
                  const Positioned(
                    left: 26,
                    right: 26,
                    bottom: 178,
                    child: _CombatFeedbackBanner(
                      text: 'Sai rồi!',
                      color: Color(0xFFE94E4E),
                      icon: Icons.warning_rounded,
                    ),
                  ),
                if (phase == BossBattlePhase.playerAttack &&
                    controller.lastBossDamage.value > 0)
                  Positioned(
                    right: 76,
                    top: compact ? 150 : 170,
                    child: _DamageText(
                      amount: controller.lastBossDamage.value,
                      color: const Color(0xFFFFD54A),
                    ),
                  ),
                if (phase == BossBattlePhase.bossAttack &&
                    controller.lastPlayerDamage.value > 0)
                  Positioned(
                    left: 68,
                    top: compact ? 235 : 258,
                    child: _DamageText(
                      amount: controller.lastPlayerDamage.value,
                      color: const Color(0xFFFF6464),
                    ),
                  ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: compact ? 90 : 104,
                  child: _QuestionOverlay(
                    controller: controller,
                    onSpeakPrompt: onSpeakPrompt,
                  ),
                ),
                Positioned(
                  left: 14,
                  bottom: 16,
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B1A1F),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFFD36C),
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x77000000),
                              blurRadius: 14,
                              offset: Offset(0, 7),
                            ),
                          ],
                        ),
                        child: const BossBattleCharacterArt(
                          kind: BossBattleCharacterKind.panda,
                          size: 44,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: math.min(220, constraints.maxWidth * .52),
                        child: BossBattleHealthBar(
                          label: '',
                          current: controller.playerHp.value,
                          max: BossBattleController.maxPlayerHp,
                          color: const Color(0xFF42D83D),
                          icon: Icons.favorite_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
                if (controller.combo.value >= 2)
                  Positioned(
                    right: 14,
                    bottom: 20,
                    child: _ComboBadge(combo: controller.combo.value),
                  ),
              ],
            ),
          );
        },
      );
    });
  }

  BossBattleCharacterMotion _pandaMotion(BossBattleController c) {
    switch (c.phase.value) {
      case BossBattlePhase.playerAttack:
        return BossBattleCharacterMotion.attack;
      case BossBattlePhase.bossAttack:
        return BossBattleCharacterMotion.hit;
      case BossBattlePhase.won:
      case BossBattlePhase.reward:
        return BossBattleCharacterMotion.victory;
      case BossBattlePhase.lost:
        return BossBattleCharacterMotion.defeat;
      default:
        return c.playerHp.value <= 30
            ? BossBattleCharacterMotion.lowHp
            : BossBattleCharacterMotion.ready;
    }
  }

  BossBattleCharacterMotion _dragonMotion(BossBattleController c) {
    switch (c.phase.value) {
      case BossBattlePhase.bossAttack:
        return BossBattleCharacterMotion.attack;
      case BossBattlePhase.playerAttack:
        return BossBattleCharacterMotion.hit;
      case BossBattlePhase.lost:
        return BossBattleCharacterMotion.victory;
      case BossBattlePhase.won:
      case BossBattlePhase.reward:
        return BossBattleCharacterMotion.defeat;
      default:
        return c.bossHp.value <= 30
            ? BossBattleCharacterMotion.lowHp
            : BossBattleCharacterMotion.idle;
    }
  }
}

class _QuestionOverlay extends StatelessWidget {
  const _QuestionOverlay({
    required this.controller,
    required this.onSpeakPrompt,
  });

  final BossBattleController controller;
  final VoidCallback onSpeakPrompt;

  @override
  Widget build(BuildContext context) {
    final question = controller.currentQuestion!;
    final canAnswer = controller.canAnswer;
    final result = controller.lastAnswerCorrect.value;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: const Color(0xFFFDF7EE),
          borderRadius: BorderRadius.circular(19),
          elevation: 10,
          shadowColor: const Color(0x66000000),
          child: InkWell(
            borderRadius: BorderRadius.circular(19),
            onTap: onSpeakPrompt,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(19),
                border: Border.all(
                  color: const Color(0xFFFFD6A1),
                  width: 1.2,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2F1FF),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF7BB9EA),
                          ),
                        ),
                        child: const Icon(
                          Icons.volume_up_rounded,
                          color: Color(0xFF318FD2),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          question.prompt,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result == null
                        ? (canAnswer
                            ? 'Chạm vào từ để nghe • Chọn đáp án đúng'
                            : controller.phaseHint)
                        : controller.feedbackText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: result == true
                          ? AppColors.success
                          : result == false
                              ? AppColors.error
                              : AppColors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: question.answers.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 9,
            crossAxisSpacing: 9,
            childAspectRatio: 2.2,
          ),
          itemBuilder: (context, index) {
            final answer = question.answers[index];
            return BossBattleAnswerButton(
              answer: answer,
              index: index,
              state: _answerState(answer, question.correctAnswer),
              onTap: canAnswer ? () => controller.answer(answer) : null,
            );
          },
        ),
      ],
    );
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
    if (answer == correctAnswer) return BossBattleAnswerVisualState.correct;
    if (answer == selected && result == false) {
      return BossBattleAnswerVisualState.wrong;
    }
    return BossBattleAnswerVisualState.disabled;
  }
}

class _BattleAttackFx extends StatelessWidget {
  const _BattleAttackFx({
    required this.phase,
    required this.index,
    required this.duration,
  });

  final BossBattlePhase phase;
  final int index;
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
            return TweenAnimationBuilder<double>(
              key: ValueKey('${phase.name}_$index'),
              tween: Tween(begin: 0, end: 1),
              duration: duration,
              curve: Curves.easeInOutCubic,
              builder: (context, value, _) {
                return CustomPaint(
                  painter: _BattleAttackPainter(
                    progress: value,
                    playerAttack: playerAttack,
                  ),
                  size: Size.infinite,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _BattleAttackPainter extends CustomPainter {
  const _BattleAttackPainter({
    required this.progress,
    required this.playerAttack,
  });

  final double progress;
  final bool playerAttack;

  @override
  void paint(Canvas canvas, Size size) {
    if (playerAttack) {
      _paintArrow(canvas, size);
    } else {
      _paintDragonFire(canvas, size);
    }
  }

  void _paintArrow(Canvas canvas, Size size) {
    final start = Offset(size.width * .26, size.height * .34);
    final end = Offset(size.width * .73, size.height * .23);
    final p = Curves.easeOutCubic.transform(progress);
    final current = Offset.lerp(start, end, p)!;
    final direction = (end - start);
    final angle = math.atan2(direction.dy, direction.dx);

    final trailPaint = Paint()
      ..color = const Color(0x88FFE8A1)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final trailStart = Offset.lerp(start, end, (p - .2).clamp(0.0, 1.0))!;
    canvas.drawLine(trailStart, current, trailPaint);

    canvas.save();
    canvas.translate(current.dx, current.dy);
    canvas.rotate(angle);

    final shaft = Paint()
      ..color = const Color(0xFF5B321E)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-28, 0), const Offset(10, 0), shaft);

    final gold = Paint()..color = const Color(0xFFFFD45A);
    final tip = Path()
      ..moveTo(17, 0)
      ..lineTo(6, -7)
      ..lineTo(6, 7)
      ..close();
    canvas.drawPath(tip, gold);

    final feather = Paint()..color = const Color(0xFFFF6D57);
    final upper = Path()
      ..moveTo(-27, 0)
      ..lineTo(-17, -7)
      ..lineTo(-13, 0)
      ..close();
    final lower = Path()
      ..moveTo(-27, 0)
      ..lineTo(-17, 7)
      ..lineTo(-13, 0)
      ..close();
    canvas.drawPath(upper, feather);
    canvas.drawPath(lower, feather);
    canvas.restore();

    if (progress > .72) {
      final impact = (progress - .72) / .28;
      final glow = Paint()
        ..shader = RadialGradient(
          colors: [
            Color.fromRGBO(255, 244, 163, (1 - impact).clamp(0, 1)),
            Color.fromRGBO(255, 157, 47, (.7 - impact * .7).clamp(0, 1)),
            const Color(0x00FF7A21),
          ],
        ).createShader(
          Rect.fromCircle(center: end, radius: 54 * impact + 12),
        );
      canvas.drawCircle(end, 54 * impact + 12, glow);
    }
  }

  void _paintDragonFire(Canvas canvas, Size size) {
    final start = Offset(size.width * .76, size.height * .24);
    final end = Offset(size.width * .27, size.height * .35);
    final p = Curves.easeInOutCubic.transform(progress);
    final head = Offset.lerp(start, end, p)!;

    for (var i = 0; i < 12; i++) {
      final t = i / 11;
      final localProgress = (p - t * .22).clamp(0.0, 1.0);
      if (localProgress <= 0) continue;

      final center = Offset.lerp(start, end, localProgress)!;
      final wobble = math.sin((t + progress) * math.pi * 5) * 9;
      final normal = Offset(-(end.dy - start.dy), end.dx - start.dx);
      final length = normal.distance == 0 ? 1 : normal.distance;
      final shifted = center + normal / length * wobble;
      final radius = 7 + (1 - t) * 9 + math.sin(progress * math.pi) * 3;

      final fire = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFFFFF),
            const Color(0xFFFFE05A),
            const Color(0xFFFF7A22),
            const Color(0x00E7341E),
          ],
        ).createShader(
          Rect.fromCircle(center: shifted, radius: radius * 2.6),
        );
      canvas.drawCircle(shifted, radius * 2.2, fire);
    }

    final core = Paint()
      ..color = const Color(0xFFFFF2A4)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, head, core);
  }

  @override
  bool shouldRepaint(covariant _BattleAttackPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.playerAttack != playerAttack;
  }
}

class _CombatFeedbackBanner extends StatelessWidget {
  const _CombatFeedbackBanner({
    required this.text,
    required this.color,
    required this.icon,
  });

  final String text;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: .88, end: 1),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      builder: (context, value, child) => Transform.scale(
        scale: value,
        child: child,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .93),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: .42),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 21),
            const SizedBox(width: 7),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DamageText extends StatelessWidget {
  const _DamageText({required this.amount, required this.color});

  final int amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Transform.translate(
        offset: Offset(0, -24 * value),
        child: Opacity(
          opacity: (1 - value * .32).clamp(0.0, 1.0),
          child: child,
        ),
      ),
      child: Text(
        '-$amount',
        style: TextStyle(
          color: color,
          fontSize: 31,
          fontWeight: FontWeight.w900,
          shadows: const [
            Shadow(color: Color(0xCC000000), blurRadius: 8),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'Combo',
            style: TextStyle(
              color: Color(0xFFFFF2D1),
              fontSize: 14,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(color: Color(0xFFFF5A2A), blurRadius: 12),
              ],
            ),
          ),
          Text(
            'x$combo',
            style: const TextStyle(
              color: Color(0xFFFFA21C),
              fontSize: 31,
              height: .9,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(color: Color(0xFFFF4A1E), blurRadius: 18),
                Shadow(color: Colors.black, blurRadius: 4),
              ],
            ),
          ),
        ],
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
      color: const Color(0xD9120B12),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(26),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8ED),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 50,
              ),
              const SizedBox(height: 10),
              const Text(
                'Không thể bắt đầu trận đấu',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.muted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 17),
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
      color: const Color(0xDD120B12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const CustomPaint(painter: _ArenaPainter()),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: won
                    ? const [
                        Color(0x33FFD968),
                        Color(0x88000000),
                        Color(0xE6120B12),
                      ]
                    : const [
                        Color(0x55A4141A),
                        Color(0x99000000),
                        Color(0xF0120B12),
                      ],
              ),
            ),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.all(22),
              constraints: const BoxConstraints(maxWidth: 430),
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
              decoration: BoxDecoration(
                color: won
                    ? const Color(0xFFFDF3D3)
                    : const Color(0xE62B171E),
                borderRadius: BorderRadius.circular(29),
                border: Border.all(
                  color: won
                      ? const Color(0xFFFFC64C)
                      : const Color(0xFF9E3D48),
                  width: 2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x99000000),
                    blurRadius: 38,
                    offset: Offset(0, 17),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    won
                        ? Icons.emoji_events_rounded
                        : Icons.heart_broken_rounded,
                    color: won
                        ? const Color(0xFFFFB000)
                        : const Color(0xFFFF7373),
                    size: 68,
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
                  const SizedBox(height: 8),
                  Text(
                    won
                        ? 'Rồng Lửa đã bị đánh bại!'
                        : 'Đừng bỏ cuộc! Hãy luyện tập thêm để mạnh hơn nhé!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: won
                          ? AppColors.muted
                          : Colors.white.withValues(alpha: .74),
                      fontSize: 13,
                      height: 1.4,
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
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: won
                                ? const Color(0xFF2CC970)
                                : const Color(0xFFFFA224),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: controller.startBattle,
                          child: Text(won ? 'Tiếp tục' : 'Thử lại'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: won
                                ? AppColors.ink
                                : const Color(0xFFFFD7D7),
                            side: BorderSide(
                              color: won
                                  ? const Color(0xFFD8C9B8)
                                  : const Color(0xFF6D3942),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => Get.back<void>(),
                          child: const Text('Về Game Hub'),
                        ),
                      ),
                    ],
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

class _ResultStat extends StatelessWidget {
  const _ResultStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .88),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.redDark,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
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

class _CenteredStatus extends StatelessWidget {
  const _CenteredStatus({
    required this.icon,
    required this.title,
    required this.message,
    this.loading = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFFFFA52A), size: 54),
            const SizedBox(height: 13),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFCDBFC7),
                height: 1.4,
              ),
            ),
            if (loading) ...[
              const SizedBox(height: 18),
              const CircularProgressIndicator(
                color: Color(0xFFFFA52A),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xB9201820),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _ArenaPainter extends CustomPainter {
  const _ArenaPainter({this.intro = false});

  final bool intro;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final sky = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: intro
            ? const [
                Color(0xFF2F57A0),
                Color(0xFF8B4B91),
                Color(0xFFF69A5E),
                Color(0xFF41222A),
              ]
            : const [
                Color(0xFF27548E),
                Color(0xFF7E4C83),
                Color(0xFFDB7456),
                Color(0xFF2E1D24),
              ],
        stops: const [0, .34, .65, 1],
      ).createShader(rect);
    canvas.drawRect(rect, sky);

    final moon = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFFFFF1C0),
          Color(0x99FFD87A),
          Color(0x00FFD87A),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * .68, size.height * .16),
          radius: size.width * .19,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * .68, size.height * .16),
      size.width * .19,
      moon,
    );

    _mountains(canvas, size);
    _pagodas(canvas, size);
    _bridge(canvas, size);
    _blossoms(canvas, size);
    _lantern(canvas, Offset(size.width * .08, size.height * .47), 9);
    _lantern(canvas, Offset(size.width * .92, size.height * .45), 10);

    final ground = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x006A403B),
          Color(0xFF2E242A),
          Color(0xFF171015),
        ],
      ).createShader(
        Rect.fromLTWH(0, size.height * .47, size.width, size.height * .53),
      );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * .47, size.width, size.height * .53),
      ground,
    );

    final path = Paint()
      ..color = const Color(0xFF59423B)
      ..style = PaintingStyle.fill;
    final pathShape = Path()
      ..moveTo(size.width * .2, size.height)
      ..lineTo(size.width * .39, size.height * .44)
      ..lineTo(size.width * .63, size.height * .44)
      ..lineTo(size.width * .86, size.height)
      ..close();
    canvas.drawPath(pathShape, path);

    final stones = Paint()
      ..color = const Color(0x665D6970)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    for (var i = 0; i < 8; i++) {
      final y = size.height * (.52 + i * .058);
      final width = size.width * (.22 + i * .055);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * .52, y),
          width: width,
          height: 12 + i * 2,
        ),
        stones,
      );
    }
  }

  void _mountains(Canvas canvas, Size size) {
    final far = Paint()..color = const Color(0x88405A78);
    final p1 = Path()
      ..moveTo(0, size.height * .45)
      ..lineTo(size.width * .14, size.height * .18)
      ..lineTo(size.width * .3, size.height * .4)
      ..lineTo(size.width * .47, size.height * .15)
      ..lineTo(size.width * .63, size.height * .42)
      ..lineTo(size.width * .82, size.height * .18)
      ..lineTo(size.width, size.height * .42)
      ..lineTo(size.width, size.height * .58)
      ..lineTo(0, size.height * .58)
      ..close();
    canvas.drawPath(p1, far);

    final near = Paint()..color = const Color(0xAA263A42);
    final p2 = Path()
      ..moveTo(0, size.height * .53)
      ..lineTo(size.width * .18, size.height * .32)
      ..lineTo(size.width * .34, size.height * .49)
      ..lineTo(size.width * .52, size.height * .29)
      ..lineTo(size.width * .72, size.height * .51)
      ..lineTo(size.width * .89, size.height * .34)
      ..lineTo(size.width, size.height * .5)
      ..lineTo(size.width, size.height * .62)
      ..lineTo(0, size.height * .62)
      ..close();
    canvas.drawPath(p2, near);
  }

  void _pagodas(Canvas canvas, Size size) {
    _pagoda(
      canvas,
      Offset(size.width * .15, size.height * .35),
      size.width * .105,
    );
    _pagoda(
      canvas,
      Offset(size.width * .34, size.height * .3),
      size.width * .075,
    );
    _pagoda(
      canvas,
      Offset(size.width * .82, size.height * .31),
      size.width * .095,
    );
  }

  void _pagoda(Canvas canvas, Offset center, double scale) {
    final wall = Paint()..color = const Color(0xFF6F3029);
    final roof = Paint()..color = const Color(0xFF17252E);
    final gold = Paint()..color = const Color(0xFFFFBE4B);

    canvas.drawRect(
      Rect.fromCenter(
        center: center.translate(0, scale * .18),
        width: scale * .8,
        height: scale * .62,
      ),
      wall,
    );

    for (var floor = 0; floor < 3; floor++) {
      final y = center.dy - scale * (.15 + floor * .28);
      final roofPath = Path()
        ..moveTo(center.dx - scale * (.62 - floor * .06), y)
        ..lineTo(center.dx, y - scale * .16)
        ..lineTo(center.dx + scale * (.62 - floor * .06), y)
        ..lineTo(center.dx + scale * .46, y + scale * .06)
        ..lineTo(center.dx - scale * .46, y + scale * .06)
        ..close();
      canvas.drawPath(roofPath, roof);
      canvas.drawCircle(
        Offset(center.dx - scale * .32, y + scale * .03),
        scale * .035,
        gold,
      );
      canvas.drawCircle(
        Offset(center.dx + scale * .32, y + scale * .03),
        scale * .035,
        gold,
      );
    }
  }

  void _bridge(Canvas canvas, Size size) {
    final rail = Paint()
      ..color = const Color(0xAA7A3934)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromLTWH(
        size.width * .15,
        size.height * .4,
        size.width * .7,
        size.height * .19,
      ),
      math.pi,
      math.pi,
      false,
      rail,
    );
  }

  void _blossoms(Canvas canvas, Size size) {
    final branch = Paint()
      ..color = const Color(0xFF3B201E)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, size.height * .12),
      Offset(size.width * .22, size.height * .29),
      branch,
    );
    canvas.drawLine(
      Offset(size.width, size.height * .13),
      Offset(size.width * .79, size.height * .3),
      branch,
    );

    final petal = Paint()..color = const Color(0xFFFF8FB6);
    for (var i = 0; i < 16; i++) {
      final left = i.isEven;
      final x = left
          ? size.width * (.025 + (i % 5) * .034)
          : size.width * (.96 - (i % 5) * .035);
      final y = size.height * (.12 + (i % 7) * .026);
      canvas.drawCircle(Offset(x, y), 4 + (i % 3).toDouble(), petal);
    }
  }

  void _lantern(Canvas canvas, Offset center, double radius) {
    final glow = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xAAFFB129),
          Color(0x33FF7A21),
          Color(0x00FF7A21),
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius * 3.2),
      );
    canvas.drawCircle(center, radius * 3.2, glow);

    final body = Paint()..color = const Color(0xFFFF6B2C);
    final edge = Paint()..color = const Color(0xFFFFD160);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: radius * 1.5,
          height: radius * 2.05,
        ),
        Radius.circular(radius * .35),
      ),
      body,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: center.translate(0, -radius * 1.08),
        width: radius * 1.15,
        height: radius * .16,
      ),
      edge,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: center.translate(0, radius * 1.08),
        width: radius * 1.15,
        height: radius * .16,
      ),
      edge,
    );
  }

  @override
  bool shouldRepaint(covariant _ArenaPainter oldDelegate) {
    return oldDelegate.intro != intro;
  }
}
