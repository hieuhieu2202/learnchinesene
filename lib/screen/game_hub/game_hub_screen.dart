import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/game_visual_tokens.dart';
import '../../core/game/game_art.dart';
import '../../widgets/game_art_image.dart';
import '../boss_battle/boss_stage_map_screen.dart';
import '../boss_battle/view/boss_battle_character_art.dart';
import '../../dragon_panda/screens/radical_builder/radical_builder_screen.dart'
    as dragon_radical;
import '../../dragon_panda/screens/tone_ninja/tone_ninja_screen.dart'
    as dragon_tone;
import '../../dragon_panda/screens/chinese_restaurant/chinese_restaurant_screen.dart'
    as dragon_restaurant;
import '../../dragon_panda/screens/quick_answer/quick_answer_screen.dart'
    as dragon_quick;

class GameHubScreen extends StatelessWidget {
  const GameHubScreen({super.key});

  static const _games = <_GamePreview>[
    _GamePreview(
      title: 'Boss Battle',
      subtitle: 'Trả lời đúng để tấn công Boss, giữ combo và mở khóa cửa ải.',
      icon: Icons.local_fire_department_rounded,
      accent: Color(0xFFE44A38),
      status: 'HOT NHẤT',
      playable: true,
    ),
    _GamePreview(
      title: 'Radical Builder',
      subtitle: 'Xây chữ Hán từ bộ thủ và ghi nhớ cấu tạo chữ.',
      icon: Icons.extension_rounded,
      accent: Color(0xFF7A64D5),
      status: 'CHƠI NGAY',
      playable: true,
    ),
    _GamePreview(
      title: 'Tone Ninja',
      subtitle: 'Luyện thanh điệu nhanh, chính xác như một ninja.',
      icon: Icons.bolt_rounded,
      accent: Color(0xFF2C84D4),
      status: 'CHƠI NGAY',
      playable: true,
    ),
    _GamePreview(
      title: 'Chinese Restaurant',
      subtitle: 'Phục vụ món ăn và luyện hội thoại nhà hàng bằng tiếng Trung.',
      icon: Icons.ramen_dining_rounded,
      accent: Color(0xFFF08A38),
      status: 'CHƠI NGAY',
      playable: true,
    ),
    _GamePreview(
      title: 'Quick Answer',
      subtitle: 'Thử phản xạ từ vựng trong bối cảnh fantasy tốc độ cao.',
      icon: Icons.speed_rounded,
      accent: Color(0xFF0EA5E9),
      status: 'CHƠI NGAY',
      playable: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const GameArtImage(
          url: GameArt.gameHubBackground,
          fit: BoxFit.cover,
          fallbackEmoji: '🏯',
        ),
        const ColoredBox(color: Color(0xE8FFF8ED)),
        Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveHelper.contentMaxWidth(context),
          ),
          child: ListView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(
              GameVisualTokens.pagePadding,
              18,
              GameVisualTokens.pagePadding,
              28,
            ),
            children: [
              const _GameHubHeader(),
              const SizedBox(height: 16),
              const _Tabs(),
              const SizedBox(height: 14),
              _FeaturedBossCard(game: _games.first),
              const SizedBox(height: 13),
              for (final game in _games.skip(1)) ...[
                _GameCard(game: game),
                const SizedBox(height: GameVisualTokens.cardGap),
              ],
            ],
          ),
        ),
      ),
    ],
  );
  }
}

class _GameHubHeader extends StatelessWidget {
  const _GameHubHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Trò chơi',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 27,
            height: 1,
            fontWeight: FontWeight.w900,
            letterSpacing: -.4,
          ),
        ),
        SizedBox(height: 7),
        Text(
          'Học tiếng Trung qua những trò chơi thú vị!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1ECE5),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE9DED2)),
      ),
      child: const Row(
        children: [
          Expanded(child: _Tab(label: 'Tất cả', active: true)),
          Expanded(child: _Tab(label: 'Đang phát triển')),
          Expanded(child: _Tab(label: 'Sắp ra mắt')),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: active ? GameVisualTokens.blue : Colors.transparent,
        borderRadius: BorderRadius.circular(13),
        boxShadow: active
            ? const [
                BoxShadow(
                  color: Color(0x332E93E8),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: active ? Colors.white : AppColors.muted,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _FeaturedBossCard extends StatelessWidget {
  const _FeaturedBossCard({required this.game});

  final _GamePreview game;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(GameVisualTokens.radiusL),
      child: InkWell(
        borderRadius: BorderRadius.circular(GameVisualTokens.radiusL),
        onTap: () => Get.to(() => const BossBattleStageMapScreen()),
        child: Container(
          height: 186,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GameVisualTokens.radiusL),
            border: Border.all(
              color: const Color(0xFFFFBF79),
              width: 1.1,
            ),
            boxShadow: GameVisualTokens.gameShadow,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const GameArtImage(
                url: GameArt.gameHubBackground,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                fallbackEmoji: '🏯',
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xE61A1016),
                      Color(0x9A1A1016),
                      Color(0x101A1016),
                    ],
                    stops: [0, .5, 1],
                  ),
                ),
              ),
              const Positioned(
                right: -4,
                bottom: -2,
                child: BossBattleCharacterArt(
                  kind: BossBattleCharacterKind.panda,
                  size: 148,
                ),
              ),
              Positioned(
                left: 16,
                right: 136,
                top: 15,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const _FlameBadge(),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            game.status,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFFFF0B9),
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .7,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      game.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.6,
                        shadows: [
                          Shadow(
                            color: Color(0xAA000000),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      game.subtitle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .88),
                        fontSize: 11.5,
                        height: 1.36,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        _MiniPill(
                          icon: Icons.swords,
                          label: 'Đánh Boss',
                        ),
                        SizedBox(width: 7),
                        _MiniPill(
                          icon: Icons.map_rounded,
                          label: 'Nhiều cửa ải',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Positioned(
                right: 10,
                top: 10,
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlameBadge extends StatelessWidget {
  const _FlameBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFE272), Color(0xFFFF7A2F)],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFFFF0B5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66FF6B29),
            blurRadius: 12,
          ),
        ],
      ),
      child: const Icon(
        Icons.local_fire_department_rounded,
        color: Colors.white,
        size: 18,
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .26),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white.withValues(alpha: .22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFFFD269), size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.game});

  final _GamePreview game;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _openGame(context),
        child: Container(
          minHeight: 96,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: game.accent.withValues(alpha: .15),
            ),
            boxShadow: GameVisualTokens.softShadow,
          ),
          child: Row(
            children: [
              _SmallArtwork(game: game),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            game.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1EFEC),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            game.playable ? 'Chơi ngay' : 'Sắp ra mắt',
                            style: TextStyle(
                              color: game.playable
                                  ? game.accent
                                  : AppColors.muted,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      game.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11.5,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFB5A9A0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openGame(BuildContext context) {
    switch (game.title) {
      case 'Radical Builder':
        Get.to(
          () => dragon_radical.RadicalBuilderScreen(
            onBack: () => Get.back<void>(),
          ),
        );
        return;
      case 'Tone Ninja':
        Get.to(
          () => dragon_tone.ToneNinjaScreen(
            onBack: () => Get.back<void>(),
          ),
        );
        return;
      case 'Chinese Restaurant':
        Get.to(
          () => dragon_restaurant.ChineseRestaurantScreen(
            onBack: () => Get.back<void>(),
          ),
        );
        return;
      case 'Quick Answer':
        Get.to(
          () => dragon_quick.QuickAnswerScreen(
            onBack: () => Get.back<void>(),
          ),
        );
        return;
      default:
        showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (_) => const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Chế độ này đang được tích hợp.'),
          ),
        );
    }
  }
}

class _SmallArtwork extends StatelessWidget {
  const _SmallArtwork({required this.game, this.large = false});

  final _GamePreview game;
  final bool large;

  String get _art {
    return switch (game.title) {
      'Boss Battle' => GameArt.bossBattleThumb,
      'Radical Builder' => GameArt.radicalBuilderThumb,
      'Tone Ninja' => GameArt.toneNinjaThumb,
      'Chinese Restaurant' => GameArt.restaurantThumb,
      _ => GameArt.quickAnswerThumb,
    };
  }

  @override
  Widget build(BuildContext context) {
    final size = large ? 80.0 : 76.0;
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: game.accent.withValues(alpha: .16),
        boxShadow: [
          BoxShadow(
            color: game.accent.withValues(alpha: .22),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          GameArtImage(
            url: _art,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            fallbackEmoji: '🎮',
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: .18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BossPreviewPainter extends CustomPainter {
  const _BossPreviewPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = GameVisualTokens.battleGradient.createShader(rect));

    final sun = Offset(size.width * .77, size.height * .26);
    canvas.drawCircle(
      sun,
      54,
      Paint()
        ..shader = const RadialGradient(
          colors: [
            Color(0xFFFFF0A0),
            Color(0x88FF9C4A),
            Color(0x00FF7B42),
          ],
        ).createShader(Rect.fromCircle(center: sun, radius: 72)),
    );

    final mountain = Paint()..color = const Color(0x99422D4A);
    final p = Path()
      ..moveTo(0, size.height * .63)
      ..lineTo(size.width * .14, size.height * .26)
      ..lineTo(size.width * .28, size.height * .58)
      ..lineTo(size.width * .46, size.height * .18)
      ..lineTo(size.width * .62, size.height * .58)
      ..lineTo(size.width * .78, size.height * .3)
      ..lineTo(size.width, size.height * .61)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(p, mountain);

    _pagoda(canvas, Offset(size.width * .18, size.height * .57), 42);
    _pagoda(canvas, Offset(size.width * .4, size.height * .64), 30);

    final ground = Paint()..color = const Color(0x9921161F);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * .72, size.width, size.height * .28),
      ground,
    );

    final ember = Paint()..color = const Color(0xB3FFD05A);
    for (var i = 0; i < 15; i++) {
      final x = ((i * 47) % 100) / 100 * size.width;
      final y = size.height * (.2 + ((i * 29) % 65) / 100);
      canvas.drawCircle(Offset(x, y), 1.2 + (i % 3) * .5, ember);
    }
  }

  void _pagoda(Canvas canvas, Offset center, double size) {
    final wall = Paint()..color = const Color(0xFFD06C48);
    final roof = Paint()..color = const Color(0xFF243D55);

    canvas.drawRect(
      Rect.fromCenter(
        center: center.translate(0, size * .18),
        width: size * .72,
        height: size * .55,
      ),
      wall,
    );

    for (var floor = 0; floor < 2; floor++) {
      final y = center.dy - size * (.04 + floor * .3);
      final path = Path()
        ..moveTo(center.dx - size * .62, y)
        ..lineTo(center.dx, y - size * .17)
        ..lineTo(center.dx + size * .62, y)
        ..lineTo(center.dx + size * .46, y + size * .08)
        ..lineTo(center.dx - size * .46, y + size * .08)
        ..close();
      canvas.drawPath(path, roof);
    }
  }

  @override
  bool shouldRepaint(covariant _BossPreviewPainter oldDelegate) => false;
}

class _MiniScenePainter extends CustomPainter {
  const _MiniScenePainter({required this.accent});

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final hill = Paint()..color = const Color(0x33220F1F);
    final path = Path()
      ..moveTo(0, size.height * .74)
      ..quadraticBezierTo(
        size.width * .25,
        size.height * .38,
        size.width * .5,
        size.height * .7,
      )
      ..quadraticBezierTo(
        size.width * .76,
        size.height * .42,
        size.width,
        size.height * .68,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, hill);

    final spark = Paint()..color = Colors.white.withValues(alpha: .32);
    for (var i = 0; i < 6; i++) {
      final a = i * math.pi / 3;
      canvas.drawCircle(
        Offset(
          size.width * .76 + math.cos(a) * 14,
          size.height * .24 + math.sin(a) * 10,
        ),
        1.6,
        spark,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MiniScenePainter oldDelegate) =>
      oldDelegate.accent != accent;
}

class _GamePreview {
  const _GamePreview({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.status,
    this.playable = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final String status;
  final bool playable;
}
