import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../boss_battle/boss_battle_screen.dart';
import '../boss_battle/view/boss_battle_character_art.dart';

class GameHubScreen extends StatelessWidget {
  const GameHubScreen({super.key});

  static const _games = <_GamePreview>[
    _GamePreview(
      title: 'Boss Battle',
      subtitle: 'Trả lời đúng để đánh bại Boss và tăng combo.',
      icon: Icons.local_fire_department_rounded,
      accent: Color(0xFFE24A36),
      status: 'Hot nhất',
      playable: true,
    ),
    _GamePreview(
      title: 'Radical Builder',
      subtitle: 'Xây chữ Hán từ bộ thủ.',
      icon: Icons.extension_rounded,
      accent: Color(0xFF7864C7),
      status: 'Sắp ra mắt',
    ),
    _GamePreview(
      title: 'Tone Ninja',
      subtitle: 'Luyện thanh điệu như ninja.',
      icon: Icons.bolt_rounded,
      accent: Color(0xFF2D7DCB),
      status: 'Sắp ra mắt',
    ),
    _GamePreview(
      title: 'Chinese Restaurant',
      subtitle: 'Phục vụ món ăn bằng tiếng Trung.',
      icon: Icons.ramen_dining_rounded,
      accent: Color(0xFFF08A38),
      status: 'Sắp ra mắt',
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
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Text(
                        'Trò chơi',
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Học tiếng Trung qua những trò chơi thú vị!',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 15),
                      _Tabs(),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                sliver: SliverList.separated(
                  itemCount: _games.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 11),
                  itemBuilder: (context, index) =>
                      _GameCard(game: _games[index], featured: index == 0),
                ),
              ),
            ],
          ),
        ),
      ),
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
        color: const Color(0xFFF3EEE7),
        borderRadius: BorderRadius.circular(16),
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
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF3194EA) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
  const _GameCard({required this.game, required this.featured});

  final _GamePreview game;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        borderRadius: BorderRadius.circular(19),
        onTap: game.playable
            ? () => Get.to(() => const BossBattleScreen())
            : () => _planned(context),
        child: Container(
          height: featured ? 116 : 92,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: game.accent.withValues(alpha: featured ? .28 : .12),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x13000000),
                blurRadius: 13,
                offset: Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              SizedBox(
                width: featured ? 116 : 92,
                height: double.infinity,
                child: _Artwork(
                  accent: game.accent,
                  icon: game.icon,
                  featured: featured,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 11, 9, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              game.title,
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: featured
                                  ? const Color(0xFFFFE2DE)
                                  : const Color(0xFFF2F0ED),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              game.status,
                              style: TextStyle(
                                color: featured
                                    ? const Color(0xFFD84A43)
                                    : AppColors.muted,
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
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFB9ADA4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _planned(BuildContext context) {
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
                color: AppColors.ink,
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

class _Artwork extends StatelessWidget {
  const _Artwork({
    required this.accent,
    required this.icon,
    required this.featured,
  });

  final Color accent;
  final IconData icon;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent,
            Color.lerp(accent, const Color(0xFF211826), .42)!,
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: -14,
            top: -12,
            child: Icon(
              icon,
              size: featured ? 92 : 74,
              color: Colors.white.withValues(alpha: .13),
            ),
          ),
          if (featured)
            const Center(
              child: BossBattleCharacterArt(
                kind: BossBattleCharacterKind.panda,
                size: 84,
              ),
            )
          else
            Center(
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .25),
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
