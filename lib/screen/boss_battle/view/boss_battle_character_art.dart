import 'dart:math' as math;

import 'package:flutter/material.dart';

enum BossBattleCharacterKind {
  panda,
  dragon,
}

class BossBattleCharacterArt extends StatelessWidget {
  const BossBattleCharacterArt({
    super.key,
    required this.kind,
    this.size = 92,
    this.defeated = false,
  });

  final BossBattleCharacterKind kind;
  final double size;
  final bool defeated;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _BossBattleCharacterPainter(
            kind: kind,
            defeated: defeated,
          ),
        ),
      ),
    );
  }
}

class _BossBattleCharacterPainter extends CustomPainter {
  const _BossBattleCharacterPainter({
    required this.kind,
    required this.defeated,
  });

  final BossBattleCharacterKind kind;
  final bool defeated;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 100;
    canvas.save();
    canvas.scale(scale, scale);

    if (kind == BossBattleCharacterKind.panda) {
      _paintPanda(canvas);
    } else {
      _paintDragon(canvas);
    }

    canvas.restore();
  }

  void _paintPanda(Canvas canvas) {
    final shadow = Paint()..color = const Color(0x33000000);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 90), width: 64, height: 12),
      shadow,
    );

    final body = Paint()..color = const Color(0xFFF8F1E7);
    final black = Paint()..color = const Color(0xFF2A2426);
    final red = Paint()..color = const Color(0xFFC83A35);
    final gold = Paint()..color = const Color(0xFFF1C45E);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 62), width: 58, height: 48),
      body,
    );

    canvas.drawCircle(const Offset(31, 30), 13, black);
    canvas.drawCircle(const Offset(69, 30), 13, black);
    canvas.drawCircle(const Offset(50, 39), 29, body);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(39, 39), width: 17, height: 22),
      black,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(61, 39), width: 17, height: 22),
      black,
    );

    final eye = Paint()
      ..color = defeated ? const Color(0xFF8B7C79) : const Color(0xFF1E1719);
    canvas.drawCircle(const Offset(40, 39), 3.4, eye);
    canvas.drawCircle(const Offset(60, 39), 3.4, eye);

    final nose = Paint()..color = const Color(0xFF33272B);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 48), width: 8, height: 5),
      nose,
    );

    final smile = Paint()
      ..color = const Color(0xFF4A373A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    if (defeated) {
      canvas.drawLine(const Offset(44, 55), const Offset(49, 58), smile);
      canvas.drawLine(const Offset(49, 58), const Offset(55, 54), smile);
    } else {
      canvas.drawArc(
        const Rect.fromLTWH(42, 49, 16, 12),
        0.2,
        math.pi - 0.4,
        false,
        smile,
      );
    }

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(28, 67), width: 16, height: 30),
      black,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(72, 67), width: 16, height: 30),
      black,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(38, 83), width: 18, height: 13),
      black,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(62, 83), width: 18, height: 13),
      black,
    );

    final scarf = Path()
      ..moveTo(25, 58)
      ..quadraticBezierTo(50, 68, 75, 58)
      ..lineTo(71, 67)
      ..quadraticBezierTo(50, 75, 29, 67)
      ..close();
    canvas.drawPath(scarf, red);

    final knot = Path()
      ..moveTo(50, 65)
      ..lineTo(60, 76)
      ..lineTo(52, 78)
      ..lineTo(45, 67)
      ..close();
    canvas.drawPath(knot, red);

    canvas.drawCircle(const Offset(50, 69), 3.4, gold);
  }

  void _paintDragon(Canvas canvas) {
    final shadow = Paint()..color = const Color(0x3D000000);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(51, 90), width: 70, height: 12),
      shadow,
    );

    final dark = Paint()..color = const Color(0xFF762521);
    final red = Paint()..color = const Color(0xFFD94B3E);
    final light = Paint()..color = const Color(0xFFFF8A52);
    final cream = Paint()..color = const Color(0xFFFFE0A3);
    final horn = Paint()..color = const Color(0xFFF0C979);
    final outline = Paint()
      ..color = const Color(0xFF4A2322)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeJoin = StrokeJoin.round;

    final tail = Path()
      ..moveTo(72, 71)
      ..cubicTo(94, 66, 95, 84, 80, 86)
      ..cubicTo(86, 78, 79, 76, 71, 79)
      ..close();
    canvas.drawPath(tail, dark);

    final leftWing = Path()
      ..moveTo(35, 56)
      ..lineTo(13, 40)
      ..lineTo(20, 63)
      ..lineTo(8, 69)
      ..lineTo(33, 72)
      ..close();
    canvas.drawPath(leftWing, dark);
    canvas.drawPath(leftWing, outline);

    final rightWing = Path()
      ..moveTo(66, 55)
      ..lineTo(90, 38)
      ..lineTo(82, 62)
      ..lineTo(94, 68)
      ..lineTo(68, 72)
      ..close();
    canvas.drawPath(rightWing, dark);
    canvas.drawPath(rightWing, outline);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(51, 68), width: 54, height: 42),
      red,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(51, 72), width: 26, height: 28),
      cream,
    );

    final neck = Path()
      ..moveTo(37, 64)
      ..quadraticBezierTo(35, 47, 44, 43)
      ..lineTo(61, 44)
      ..quadraticBezierTo(68, 51, 66, 65)
      ..close();
    canvas.drawPath(neck, red);

    final head = Path()
      ..moveTo(29, 36)
      ..quadraticBezierTo(35, 18, 53, 17)
      ..quadraticBezierTo(72, 18, 79, 36)
      ..quadraticBezierTo(77, 55, 54, 58)
      ..quadraticBezierTo(31, 55, 29, 36)
      ..close();
    canvas.drawPath(head, red);
    canvas.drawPath(head, outline);

    final snout = Path()
      ..moveTo(39, 43)
      ..quadraticBezierTo(54, 38, 68, 43)
      ..quadraticBezierTo(65, 55, 53, 56)
      ..quadraticBezierTo(42, 55, 39, 43)
      ..close();
    canvas.drawPath(snout, light);

    final leftHorn = Path()
      ..moveTo(38, 21)
      ..quadraticBezierTo(28, 8, 29, 4)
      ..quadraticBezierTo(39, 10, 45, 18)
      ..close();
    final rightHorn = Path()
      ..moveTo(65, 20)
      ..quadraticBezierTo(77, 9, 76, 4)
      ..quadraticBezierTo(67, 9, 59, 18)
      ..close();
    canvas.drawPath(leftHorn, horn);
    canvas.drawPath(rightHorn, horn);

    final brow = Paint()
      ..color = const Color(0xFF5D221F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(39, 31), const Offset(47, 29), brow);
    canvas.drawLine(const Offset(58, 29), const Offset(67, 31), brow);

    final eye = Paint()
      ..color = defeated ? const Color(0xFF9C7772) : const Color(0xFFFFF4C8);
    canvas.drawCircle(const Offset(44, 35), 4.2, eye);
    canvas.drawCircle(const Offset(63, 35), 4.2, eye);

    final pupil = Paint()..color = const Color(0xFF241515);
    if (!defeated) {
      canvas.drawCircle(const Offset(45, 35), 1.7, pupil);
      canvas.drawCircle(const Offset(62, 35), 1.7, pupil);
    } else {
      final xPaint = Paint()
        ..color = const Color(0xFF5A2A27)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;
      for (final center in const <Offset>[Offset(44, 35), Offset(63, 35)]) {
        canvas.drawLine(
          center.translate(-3, -3),
          center.translate(3, 3),
          xPaint,
        );
        canvas.drawLine(
          center.translate(3, -3),
          center.translate(-3, 3),
          xPaint,
        );
      }
    }

    final nose = Paint()..color = const Color(0xFF6B2A25);
    canvas.drawCircle(const Offset(47, 47), 1.8, nose);
    canvas.drawCircle(const Offset(60, 47), 1.8, nose);

    final fang = Paint()..color = Colors.white;
    final leftFang = Path()
      ..moveTo(44, 50)
      ..lineTo(48, 50)
      ..lineTo(46, 56)
      ..close();
    final rightFang = Path()
      ..moveTo(58, 50)
      ..lineTo(62, 50)
      ..lineTo(60, 56)
      ..close();
    canvas.drawPath(leftFang, fang);
    canvas.drawPath(rightFang, fang);

    for (final y in <double>[64, 72, 80]) {
      canvas.drawArc(
        Rect.fromCenter(center: Offset(51, y), width: 20, height: 8),
        0,
        math.pi,
        false,
        Paint()
          ..color = const Color(0xFFCC9A52)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BossBattleCharacterPainter oldDelegate) {
    return oldDelegate.kind != kind || oldDelegate.defeated != defeated;
  }
}
