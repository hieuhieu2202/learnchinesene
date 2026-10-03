import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/game/game_art.dart';
import '../../core/theme/app_colors.dart';
import '../../features/hanzi_writing/screens/hanzi_writing_home_screen.dart';
import '../../widgets/game_network_image.dart';
import '../flashcards/flashcards_screen.dart';
import '../hsk/hsk_screen.dart';
import '../hsk_quiz/hsk_quiz_screen.dart';
import '../speaking/speaking_screen.dart';

class GameHubScreen extends StatelessWidget {
  const GameHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final games = <_GameEntry>[
      _GameEntry(
        title: 'Boss Battle',
        subtitle: 'Chinh phục thử thách HSK như một trận đấu',
        art: GameArt.bossThumb,
        badge: 'HOT',
        gradient: const [Color(0xFF8B0000), Color(0xFFD32F2F), Color(0xFFFF6F00)],
        onTap: () => Get.to(() => const HskQuizScreen()),
      ),
      _GameEntry(
        title: 'Xây chữ Hán',
        subtitle: 'Ghi nhớ mặt chữ qua từng nét',
        art: GameArt.radicalBuilderThumb,
        gradient: const [Color(0xFF0F766E), Color(0xFF10B981)],
        onTap: () => Get.to(() => const HanziWritingHomeScreen()),
      ),
      _GameEntry(
        title: 'Tone Ninja',
        subtitle: 'Phản xạ thanh điệu và luyện phát âm',
        art: GameArt.toneNinjaThumb,
        gradient: const [Color(0xFF4338CA), Color(0xFF7C3AED)],
        onTap: () => Get.to(
          () => const SpeakingScreen(),
          arguments: const {'standalone': true},
        ),
      ),
      _GameEntry(
        title: 'Flashcard Quest',
        subtitle: 'Lật thẻ, ghi nhớ và lên chuỗi chiến thắng',
        art: GameArt.restaurantThumb,
        gradient: const [Color(0xFFB45309), Color(0xFFF59E0B)],
        onTap: () => Get.to(() => const FlashcardsScreen()),
      ),
      _GameEntry(
        title: 'Quick Answer',
        subtitle: 'Thử tốc độ phản xạ từ vựng HSK',
        art: GameArt.quickAnswerThumb,
        gradient: const [Color(0xFF0369A1), Color(0xFF0EA5E9)],
        onTap: () => Get.to(() => const HskScreen()),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          GameNetworkImage(
            url: GameArt.gameHubBackground,
            fit: BoxFit.cover,
            fallbackEmoji: '🏯',
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: .38),
                  Colors.black.withValues(alpha: .62),
                  const Color(0xFF0F172A).withValues(alpha: .96),
                ],
                stops: const [0, .48, 1],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 16, 6),
                  child: Row(
                    children: [
                      _GlassIcon(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: Get.back,
                      ),
                      const Expanded(
                        child: Column(
                          children: [
                            Text(
                              '冒险模式',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              'Game Hub',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
                                shadows: [
                                  Shadow(color: Colors.black54, blurRadius: 8),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 44),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Text(
                    'Học tiếng Trung theo cách của một cuộc phiêu lưu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFDCE4F0),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                    itemCount: games.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (_, index) => TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 320 + index * 70),
                      tween: Tween(begin: 0, end: 1),
                      curve: Curves.easeOutCubic,
                      builder: (_, value, child) => Transform.translate(
                        offset: Offset(0, 26 * (1 - value)),
                        child: Opacity(opacity: value, child: child),
                      ),
                      child: _GameCard(entry: games[index]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatefulWidget {
  const _GameCard({required this.entry});
  final _GameEntry entry;

  @override
  State<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<_GameCard> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    return GestureDetector(
      onTapDown: (_) => setState(() => pressed = true),
      onTapCancel: () => setState(() => pressed = false),
      onTapUp: (_) {
        setState(() => pressed = false);
        entry.onTap();
      },
      child: AnimatedScale(
        scale: pressed ? .975 : 1,
        duration: const Duration(milliseconds: 110),
        child: Container(
          height: 112,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: entry.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: .28)),
            boxShadow: [
              BoxShadow(
                color: entry.gradient.first.withValues(alpha: .34),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                right: -8,
                top: -16,
                bottom: -20,
                width: 138,
                child: Opacity(
                  opacity: .94,
                  child: GameNetworkImage(
                    url: entry.art,
                    fit: BoxFit.cover,
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: .24),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 126, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            entry.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (entry.badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.gold,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              entry.badge!,
                              style: const TextStyle(
                                color: Color(0xFF4A2A00),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      entry.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .86),
                        fontSize: 12,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    const Row(
                      children: [
                        Icon(
                          Icons.play_circle_fill_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Chơi ngay',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassIcon extends StatelessWidget {
  const _GlassIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.black.withValues(alpha: .34),
        shape: const CircleBorder(),
        child: IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: Colors.white, size: 20),
        ),
      );
}

class _GameEntry {
  const _GameEntry({
    required this.title,
    required this.subtitle,
    required this.art,
    required this.gradient,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String subtitle;
  final String art;
  final List<Color> gradient;
  final VoidCallback onTap;
  final String? badge;
}
