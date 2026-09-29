import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/responsive/responsive_layout.dart';

class GameHubScreen extends StatelessWidget {
  const GameHubScreen({super.key});

  static const _games = <_GamePreview>[
    _GamePreview(
      title: 'Boss Battle',
      subtitle: 'Trả lời đúng để tung đòn, phá giáp và hạ boss.',
      icon: Icons.local_fire_department_rounded,
      accent: Color(0xFFE05A3F),
      status: 'Ưu tiên phát triển',
      statusColor: Color(0xFFE05A3F),
      skills: ['Từ vựng', 'Pinyin', 'Ngữ nghĩa'],
    ),
    _GamePreview(
      title: 'Radical Builder',
      subtitle: 'Ghép bộ thủ và thành phần để tạo chữ Hán đúng.',
      icon: Icons.extension_rounded,
      accent: Color(0xFF9B6BCE),
      status: 'Chuẩn bị',
      statusColor: Color(0xFF7F67B5),
      skills: ['Bộ thủ', 'Hán tự'],
    ),
    _GamePreview(
      title: 'Tone Ninja',
      subtitle: 'Nhận diện thanh điệu và chém đúng mục tiêu.',
      icon: Icons.bolt_rounded,
      accent: Color(0xFF3F8FD2),
      status: 'Chuẩn bị',
      statusColor: Color(0xFF3F8FD2),
      skills: ['Pinyin', 'Thanh điệu'],
    ),
    _GamePreview(
      title: 'Chinese Restaurant',
      subtitle: 'Phục vụ món ăn bằng từ vựng và câu giao tiếp đúng.',
      icon: Icons.ramen_dining_rounded,
      accent: Color(0xFFF08B38),
      status: 'Chuẩn bị',
      statusColor: Color(0xFFF08B38),
      skills: ['Hội thoại', 'Ngữ cảnh'],
    ),
    _GamePreview(
      title: 'Stroke Order Dojo',
      subtitle: 'Luyện thứ tự nét và ghi nhớ cấu trúc chữ Hán.',
      icon: Icons.draw_rounded,
      accent: Color(0xFFC04D55),
      status: 'Cần dữ liệu nét',
      statusColor: Color(0xFF9A5960),
      skills: ['Viết chữ', 'Hán tự'],
    ),
    _GamePreview(
      title: 'Listening Detective',
      subtitle: 'Nghe câu tiếng Trung và tìm bối cảnh phù hợp.',
      icon: Icons.hearing_rounded,
      accent: Color(0xFF3B8F8B),
      status: 'Chuẩn bị',
      statusColor: Color(0xFF3B8F8B),
      skills: ['Nghe', 'Ngữ cảnh'],
    ),
    _GamePreview(
      title: 'Hanzi Memory Match',
      subtitle: 'Ghép Hán tự với pinyin, nghĩa hoặc hình ảnh.',
      icon: Icons.grid_view_rounded,
      accent: Color(0xFFD16A92),
      status: 'Chuẩn bị',
      statusColor: Color(0xFFD16A92),
      skills: ['Ghi nhớ', 'Từ vựng'],
    ),
    _GamePreview(
      title: 'Sentence Train',
      subtitle: 'Sắp xếp các toa từ vựng để tạo câu đúng.',
      icon: Icons.train_rounded,
      accent: Color(0xFFCC7B2F),
      status: 'Chuẩn bị',
      statusColor: Color(0xFFCC7B2F),
      skills: ['Ngữ pháp', 'Câu'],
    ),
    _GamePreview(
      title: 'Pronunciation Battle',
      subtitle: 'Luyện nói và biến độ chính xác thành sức mạnh.',
      icon: Icons.mic_rounded,
      accent: Color(0xFF5E79D8),
      status: 'Cần scoring phát âm',
      statusColor: Color(0xFF5E79D8),
      skills: ['Phát âm', 'Nói'],
    ),
    _GamePreview(
      title: 'Treasure Map',
      subtitle: 'Vượt thử thách, nhận sao và mở khóa kho báu.',
      icon: Icons.map_rounded,
      accent: Color(0xFF4F9A5A),
      status: 'Meta progression',
      statusColor: Color(0xFF4F9A5A),
      skills: ['Ôn tập', 'Tiến trình'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ResponsiveHelper.contentMaxWidth(context),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useGrid = constraints.maxWidth >= 680;
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  sliver: SliverToBoxAdapter(
                    child: _GameHero(gameCount: _games.length),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Kho trò chơi',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.red.withValues(alpha: .08),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${_games.length} ý tưởng',
                            style: const TextStyle(
                              color: AppColors.redDark,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (useGrid)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 1.3,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _GameCard(game: _games[index]),
                        childCount: _games.length,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    sliver: SliverList.separated(
                      itemCount: _games.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _GameCard(game: _games[index]),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GameHero extends StatelessWidget {
  const _GameHero({required this.gameCount});

  final int gameCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.redDark,
            AppColors.red,
            AppColors.orange,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2EB4232C),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -14,
            top: -18,
            child: Icon(
              Icons.sports_esports_rounded,
              size: 120,
              color: Colors.white.withValues(alpha: .10),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .18),
                  ),
                ),
                child: const Text(
                  'GAME LAB',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Học tiếng Trung\nnhư đang chơi game',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$gameCount mini-game được thiết kế quanh dữ liệu học thật. '
                'Boss Battle sẽ là vertical slice đầu tiên.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .86),
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _HeroBadge(
                    icon: Icons.auto_awesome_rounded,
                    label: '2D / 2.5D',
                  ),
                  const SizedBox(width: 8),
                  _HeroBadge(
                    icon: Icons.school_rounded,
                    label: 'Learning-first',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .14),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
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
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _showPlannedGameInfo(context, game),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: game.accent.withValues(alpha: .14),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          game.accent.withValues(alpha: .90),
                          game.accent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(17),
                      boxShadow: [
                        BoxShadow(
                          color: game.accent.withValues(alpha: .24),
                          blurRadius: 12,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Icon(game.icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game.title,
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: game.statusColor.withValues(alpha: .10),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            game.status,
                            style: TextStyle(
                              color: game.statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.muted,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                game.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final skill in game.skills)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F5F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        skill,
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
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

  void _showPlannedGameInfo(BuildContext context, _GamePreview game) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: game.accent.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(game.icon, color: game.accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      game.title,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                game.subtitle,
                style: const TextStyle(
                  color: AppColors.muted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Trạng thái hiện tại: đây là game đã được lên concept và '
                'đang chờ triển khai theo roadmap. Không tạo màn hình giả '
                'hoặc hardcode dữ liệu chỉ để bật nút chơi.',
                style: TextStyle(height: 1.45),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Đã hiểu'),
                ),
              ),
            ],
          ),
        ),
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
    required this.statusColor,
    required this.skills,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final String status;
  final Color statusColor;
  final List<String> skills;
}
