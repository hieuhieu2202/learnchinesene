import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/responsive/responsive_layout.dart';
import '../boss_battle/boss_battle_screen.dart';
import '../boss_battle/view/boss_battle_character_art.dart';

class GameHubScreen extends StatelessWidget {
  const GameHubScreen({super.key});

  static const _games = <_GamePreview>[
    _GamePreview(
      title: 'Boss Battle',
      subtitle: 'Trả lời đúng để tung đòn, phá giáp và hạ Rồng Lửa.',
      icon: Icons.local_fire_department_rounded,
      accent: Color(0xFFE44B37),
      playable: true,
      badge: 'Ưu tiên phát triển',
    ),
    _GamePreview(
      title: 'Radical Builder',
      subtitle: 'Xây chữ Hán từ bộ thủ và thành phần.',
      icon: Icons.extension_rounded,
      accent: Color(0xFF8C62C9),
      badge: 'Sắp ra mắt',
    ),
    _GamePreview(
      title: 'Tone Ninja',
      subtitle: 'Luyện thanh điệu nhanh như một ninja.',
      icon: Icons.bolt_rounded,
      accent: Color(0xFF377ED8),
      badge: 'Sắp ra mắt',
    ),
    _GamePreview(
      title: 'Chinese Restaurant',
      subtitle: 'Phục vụ món ăn bằng tiếng Trung.',
      icon: Icons.ramen_dining_rounded,
      accent: Color(0xFFF08B38),
      badge: 'Sắp ra mắt',
    ),
    _GamePreview(
      title: 'Stroke Order Dojo',
      subtitle: 'Luyện thứ tự nét và cấu trúc chữ Hán.',
      icon: Icons.draw_rounded,
      accent: Color(0xFFC75058),
      badge: 'Đang phát triển',
    ),
    _GamePreview(
      title: 'Listening Detective',
      subtitle: 'Nghe câu và tìm bối cảnh phù hợp.',
      icon: Icons.hearing_rounded,
      accent: Color(0xFF318E8A),
      badge: 'Đang phát triển',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFFFFAF2),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveHelper.contentMaxWidth(context),
          ),
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const Text(
                        'Trò chơi',
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Học tiếng Trung qua những trò chơi thú vị!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _FilterBar(),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
                sliver: SliverList.separated(
                  itemCount: _games.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _GameCard(game: _games[index], index: index),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EEE5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Expanded(child: _FilterChip(label: 'Tất cả', active: true)),
          Expanded(child: _FilterChip(label: 'Đang phát triển')),
          Expanded(child: _FilterChip(label: 'Sắp ra mắt')),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF5AA9E6) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: active
            ? const [
                BoxShadow(
                  color: Color(0x225AA9E6),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : AppColors.muted,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.game, required this.index});

  final _GamePreview game;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isBoss = index == 0;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        borderRadius: BorderRadius.circular(19),
        onTap: game.playable
            ? () => Get.to(() => const BossBattleScreen())
            : () => _showPlanned(context),
        child: Container(
          height: isBoss ? 118 : 94,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: game.accent.withValues(alpha: isBoss ? .28 : .12),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 13,
                offset: Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              SizedBox(
                width: isBoss ? 118 : 92,
                height: double.infinity,
                child: _GameArtwork(
                  accent: game.accent,
                  icon: game.icon,
                  boss: isBoss,
                  index: index,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
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
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          if (isBoss)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE2E0),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: const Text(
                                'Ưu tiên phát triển',
                                style: TextStyle(
                                  color: Color(0xFFD84A45),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(
                        game.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                      if (!isBoss) ...[
                        const SizedBox(height: 6),
                        Text(
                          game.badge,
                          style: TextStyle(
                            color: game.accent.withValues(alpha: .88),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFB7AAA0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlanned(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: const Color(0xFFFFFAF2),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(game.icon, color: game.accent, size: 42),
            const SizedBox(height: 10),
            Text(
              game.title,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              game.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.muted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Get.back<void>(),
                child: const Text('Đã hiểu'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameArtwork extends StatelessWidget {
  const _GameArtwork({
    required this.accent,
    required this.icon,
    required this.boss,
    required this.index,
  });

  final Color accent;
  final IconData icon;
  final bool boss;
  final int index;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: .98),
            Color.lerp(accent, const Color(0xFF251A2C), .35)!,
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: -16,
            top: -14,
            child: Icon(
              icon,
              size: boss ? 94 : 78,
              color: Colors.white.withValues(alpha: .12),
            ),
          ),
          if (boss)
            const Center(
              child: BossBattleCharacterArt(
                kind: BossBattleCharacterKind.panda,
                size: 86,
              ),
            )
          else
            Center(
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .18),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .28),
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
            ),
        ],
      ),
    );
  }
}

class _GamePreview {
  const _GamePreview({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.badge,
    this.playable = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final String badge;
  final bool playable;
}
