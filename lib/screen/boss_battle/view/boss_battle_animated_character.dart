import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../animation/boss_battle_rive_contract.dart';
import 'boss_battle_character_art.dart';

class BossBattleAnimatedCharacter extends StatefulWidget {
  const BossBattleAnimatedCharacter({
    super.key,
    required this.kind,
    required this.motion,
    required this.size,
    this.defeated = false,
    this.flipX = false,
  });

  final BossBattleCharacterKind kind;
  final BossBattleCharacterMotion motion;
  final double size;
  final bool defeated;
  final bool flipX;

  @override
  State<BossBattleAnimatedCharacter> createState() =>
      _BossBattleAnimatedCharacterState();
}

class _BossBattleAnimatedCharacterState
    extends State<BossBattleAnimatedCharacter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds:
            widget.kind == BossBattleCharacterKind.dragon ? 1200 : 940,
      ),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final wave = math.sin(_controller.value * math.pi);
            final motion = widget.motion;

            final bob = switch (motion) {
              BossBattleCharacterMotion.defeat => 0.0,
              BossBattleCharacterMotion.hit => wave * 1.2,
              BossBattleCharacterMotion.attack => -wave * 2.2,
              BossBattleCharacterMotion.victory => -wave * 4.5,
              BossBattleCharacterMotion.lowHp => wave * 1.4,
              _ => -wave * 2.7,
            };

            final lunge = motion == BossBattleCharacterMotion.attack
                ? wave *
                    (widget.kind == BossBattleCharacterKind.dragon ? 14 : 18) *
                    (widget.flipX ? -1 : 1)
                : 0.0;

            final rotation = switch (motion) {
              BossBattleCharacterMotion.hit =>
                math.sin(_controller.value * math.pi * 5) * .04,
              BossBattleCharacterMotion.victory =>
                math.sin(_controller.value * math.pi * 2) * .03,
              BossBattleCharacterMotion.attack =>
                (widget.flipX ? -1 : 1) * wave * .035,
              BossBattleCharacterMotion.lowHp =>
                math.sin(_controller.value * math.pi * 2) * .015,
              _ => 0.0,
            };

            final scaleY = switch (motion) {
              BossBattleCharacterMotion.defeat => .92,
              BossBattleCharacterMotion.hit => .97,
              BossBattleCharacterMotion.attack => 1.03,
              BossBattleCharacterMotion.victory => 1 + wave * .06,
              BossBattleCharacterMotion.lowHp => 1 + wave * .012,
              _ => 1 + wave * .024,
            };

            return Transform.translate(
              offset: Offset(lunge, bob),
              child: Transform.rotate(
                angle: rotation,
                child: Transform.scale(
                  scaleY: scaleY,
                  alignment: Alignment.bottomCenter,
                  child: Transform.flip(
                    flipX: widget.flipX,
                    child: child,
                  ),
                ),
              ),
            );
          },
          child: BossBattleCharacterArt(
            kind: widget.kind,
            size: widget.size,
            defeated: widget.defeated,
          ),
        ),
      ),
    );
  }
}
