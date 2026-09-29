import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../controller/boss_battle_controller.dart';

class BossBattleCartoonAttackFx extends StatelessWidget {
  const BossBattleCartoonAttackFx({
    super.key,
    required this.phase,
    required this.index,
    required this.duration,
  });

  final BossBattlePhase phase;
  final int index;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final pandaAttack = phase == BossBattlePhase.playerAttack;
    final dragonAttack = phase == BossBattlePhase.bossAttack;
    if (!pandaAttack && !dragonAttack) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: RepaintBoundary(
          child: TweenAnimationBuilder<double>(
            key: ValueKey('${phase.name}_$index'),
            tween: Tween(begin: 0, end: 1),
            duration: duration,
            curve: Curves.easeInOutCubic,
            builder: (context, progress, _) {
              return CustomPaint(
                painter: _CartoonAttackPainter(
                  progress: progress,
                  dragonAttack: dragonAttack,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CartoonAttackPainter extends CustomPainter {
  const _CartoonAttackPainter({
    required this.progress,
    required this.dragonAttack,
  });

  final double progress;
  final bool dragonAttack;

  @override
  void paint(Canvas canvas, Size size) {
    if (dragonAttack) {
      _paintDragonBreath(canvas, size);
    } else {
      _paintPandaArrow(canvas, size);
    }
  }

  void _paintDragonBreath(Canvas canvas, Size size) {
    final mouth = Offset(size.width * .73, size.height * .22);
    final target = Offset(size.width * .29, size.height * .35);

    if (progress < .18) {
      final charge = Curves.easeOut.transform(progress / .18);
      final glowRadius = 12 + charge * 20;
      final glow = Paint()
        ..shader = const RadialGradient(
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFFEC66),
            Color(0xFFFF7A1A),
            Color(0x00FF2D00),
          ],
        ).createShader(
          Rect.fromCircle(center: mouth, radius: glowRadius * 2.2),
        );
      canvas.drawCircle(mouth, glowRadius * 2.1, glow);
      return;
    }

    final travel = ((progress - .18) / .62).clamp(0.0, 1.0);
    final eased = Curves.easeOutCubic.transform(travel);
    final head = Offset.lerp(mouth, target, eased)!;
    final dir = head - mouth;
    final length = math.max(1.0, dir.distance);
    final normal = Offset(-dir.dy / length, dir.dx / length);

    final pulse = math.sin(progress * math.pi * 8);
    final outer = Path()..moveTo(mouth.dx, mouth.dy);
    final inner = Path()..moveTo(mouth.dx, mouth.dy);

    for (var i = 1; i <= 12; i++) {
      final t = i / 12;
      final center = Offset.lerp(mouth, head, t)!;
      final wave = math.sin(
            t * math.pi * 4.5 + progress * math.pi * 10,
          ) *
          (8 + t * 8);
      final width = (13 + t * 23) * (0.9 + pulse.abs() * .12);
      final upper = center + normal * (wave + width);
      final lower = center + normal * (wave - width);

      if (i == 1) {
        outer.lineTo(upper.dx, upper.dy);
      } else {
        outer.quadraticBezierTo(
          center.dx - dir.dx / 24,
          center.dy - dir.dy / 24,
          upper.dx,
          upper.dy,
        );
      }

      inner.lineTo(
        center.dx + normal.dx * (wave + width * .35),
        center.dy + normal.dy * (wave + width * .35),
      );
      if (i == 12) {
        outer.lineTo(head.dx + 18, head.dy);
      }
    }

    for (var i = 12; i >= 1; i--) {
      final t = i / 12;
      final center = Offset.lerp(mouth, head, t)!;
      final wave = math.sin(
            t * math.pi * 4.5 + progress * math.pi * 10,
          ) *
          (8 + t * 8);
      final width = (13 + t * 23) * (0.9 + pulse.abs() * .12);
      final lower = center + normal * (wave - width);
      outer.lineTo(lower.dx, lower.dy);
    }
    outer.close();

    canvas.drawPath(
      outer,
      Paint()
        ..shader = LinearGradient(
          colors: const [
            Color(0xFFFFF3A0),
            Color(0xFFFFB11F),
            Color(0xFFFF5A18),
            Color(0xFFE52E1B),
          ],
          stops: const [0, .28, .68, 1],
        ).createShader(
          Rect.fromPoints(mouth, head),
        ),
    );

    final core = Paint()
      ..color = const Color(0xFFFFF8BF)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(mouth, head, core);

    for (var i = 0; i < 18; i++) {
      final t = ((i * .071) + progress * .72) % 1;
      if (t > eased) continue;
      final center = Offset.lerp(mouth, target, t)!;
      final wobble = math.sin(i * 1.7 + progress * 14) * (9 + t * 15);
      final sparkCenter = center + normal * wobble;
      final radius = 2.2 + (i % 4) * .8;
      canvas.drawCircle(
        sparkCenter,
        radius,
        Paint()
          ..color = i.isEven
              ? const Color(0xFFFFED6C)
              : const Color(0xFFFF7A22),
      );
    }

    if (progress > .72) {
      final impact = ((progress - .72) / .28).clamp(0.0, 1.0);
      final radius = 26 + impact * 58;
      canvas.drawCircle(
        target,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Color.fromRGBO(
                255,
                255,
                220,
                (1 - impact * .45).clamp(0, 1),
              ),
              Color.fromRGBO(
                255,
                122,
                24,
                (.82 - impact * .72).clamp(0, 1),
              ),
              const Color(0x00F22F16),
            ],
          ).createShader(
            Rect.fromCircle(center: target, radius: radius),
          ),
      );

      final ring = Paint()
        ..color = Color.fromRGBO(
          255,
          216,
          81,
          (1 - impact).clamp(0, 1),
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5;
      canvas.drawCircle(target, 18 + impact * 64, ring);
    }
  }

  void _paintPandaArrow(Canvas canvas, Size size) {
    final start = Offset(size.width * .28, size.height * .34);
    final target = Offset(size.width * .72, size.height * .23);

    if (progress < .2) {
      final charge = progress / .2;
      canvas.drawCircle(
        start,
        18 + charge * 16,
        Paint()
          ..color = Color.fromRGBO(
            255,
            211,
            80,
            (.2 + charge * .45).clamp(0, 1),
          ),
      );
      return;
    }

    final travel = ((progress - .2) / .58).clamp(0.0, 1.0);
    final p = Curves.easeOutCubic.transform(travel);
    final head = Offset.lerp(start, target, p)!;
    final direction = target - start;
    final angle = math.atan2(direction.dy, direction.dx);

    final trailStart = Offset.lerp(
      start,
      target,
      (p - .24).clamp(0.0, 1.0),
    )!;
    canvas.drawLine(
      trailStart,
      head,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0x00FFD95D),
            Color(0xFFFFD95D),
            Color(0xFFFFFFFF),
          ],
        ).createShader(Rect.fromPoints(trailStart, head))
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );

    canvas.save();
    canvas.translate(head.dx, head.dy);
    canvas.rotate(angle);

    canvas.drawLine(
      const Offset(-32, 0),
      const Offset(9, 0),
      Paint()
        ..color = const Color(0xFF5B321E)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    final tip = Path()
      ..moveTo(18, 0)
      ..lineTo(6, -8)
      ..lineTo(6, 8)
      ..close();
    canvas.drawPath(
      tip,
      Paint()..color = const Color(0xFFFFD45A),
    );

    final topFeather = Path()
      ..moveTo(-31, 0)
      ..lineTo(-18, -8)
      ..lineTo(-13, 0)
      ..close();
    final bottomFeather = Path()
      ..moveTo(-31, 0)
      ..lineTo(-18, 8)
      ..lineTo(-13, 0)
      ..close();
    final feather = Paint()..color = const Color(0xFFFF6454);
    canvas.drawPath(topFeather, feather);
    canvas.drawPath(bottomFeather, feather);
    canvas.restore();

    if (progress > .74) {
      final impact = ((progress - .74) / .26).clamp(0.0, 1.0);
      final burst = Paint()
        ..color = Color.fromRGBO(
          255,
          214,
          70,
          (1 - impact).clamp(0, 1),
        )
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;

      for (var i = 0; i < 10; i++) {
        final a = i * math.pi * 2 / 10;
        final inner = 14 + impact * 8;
        final outer = 24 + impact * 46;
        canvas.drawLine(
          target + Offset(math.cos(a), math.sin(a)) * inner,
          target + Offset(math.cos(a), math.sin(a)) * outer,
          burst,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CartoonAttackPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.dragonAttack != dragonAttack;
  }
}
