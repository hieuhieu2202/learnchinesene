import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_navigation.dart';

/// REQUIRED ASSETS:
/// 1. Background: assets/images/backgrounds/game_hub_bg.png
/// 2. Icons:      assets/images/icons/boss_battle_thumb.png
///                assets/images/icons/radical_builder_thumb.png
///                assets/images/icons/tone_ninja_thumb.png
///                assets/images/icons/restaurant_thumb.png
///                assets/images/icons/quick_answer_thumb.png
class GameHubScreen extends StatelessWidget {
  final VoidCallback onSelectBossBattle;
  final VoidCallback onSelectRadicalBuilder;
  final VoidCallback onSelectToneNinja;
  final VoidCallback onSelectRestaurant;
  final VoidCallback onSelectQuickAnswer;
  final VoidCallback onBackToHome;

  const GameHubScreen({
    Key? key,
    required this.onSelectBossBattle,
    required this.onSelectRadicalBuilder,
    required this.onSelectToneNinja,
    required this.onSelectRestaurant,
    required this.onSelectQuickAnswer,
    required this.onBackToHome,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ==========================================
          // LAYER 0: PURE BACKGROUND ART
          // REQUIRED ASSET: assets/images/backgrounds/game_hub_bg.png
          // ==========================================
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgrounds/game_hub_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // Atmospheric Dark Tint for Card Contrast
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.45),
            ),
          ),

          // ==========================================
          // LAYER 1: FLUTTER GAME CARDS & NAVIGATION
          // ==========================================
          SafeArea(
            child: Column(
              children: [
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.35), shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                          onPressed: onBackToHome,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Trò chơi',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 6, offset: Offset(0, 2)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 44), // Balances back button width
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Học tiếng Trung qua những trò chơi thú vị!',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFCBD5E1),
                            shadows: [
                              Shadow(color: Colors.black87, blurRadius: 4),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 1. BOSS BATTLE (Hero Highlighted Game Card)
                        _buildGameCard(
                          title: 'Boss Battle',
                          description: 'Đánh bại Boss bằng kiến thức tiếng Trung!',
                          assetPath: 'assets/images/icons/boss_battle_thumb.png',
                          badge: 'HOT',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B0000), Color(0xFFD32F2F), Color(0xFFFF6F00)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          onTap: onSelectBossBattle,
                        ),
                        const SizedBox(height: 14),

                        // 2. XÂY CHỮ HÁN
                        _buildGameCard(
                          title: 'Xây chữ Hán',
                          description: 'Xây chữ Hán từ bộ thủ',
                          assetPath: 'assets/images/icons/radical_builder_thumb.png',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          onTap: onSelectRadicalBuilder,
                        ),
                        const SizedBox(height: 14),

                        // 3. TONE NINJA
                        _buildGameCard(
                          title: 'Tone Ninja',
                          description: 'Luyện thanh điệu như ninja',
                          assetPath: 'assets/images/icons/tone_ninja_thumb.png',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4338CA), Color(0xFF6366F1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          onTap: onSelectToneNinja,
                        ),
                        const SizedBox(height: 14),

                        // 4. NHÀ HÀNG TRUNG HOA
                        _buildGameCard(
                          title: 'Nhà hàng Trung Hoa',
                          description: 'Phục vụ món ăn bằng tiếng Trung',
                          assetPath: 'assets/images/icons/restaurant_thumb.png',
                          gradient: const LinearGradient(
                            colors: [Color(0xFFB45309), Color(0xFFD97706)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          onTap: onSelectRestaurant,
                        ),
                        const SizedBox(height: 14),

                        // 5. TRẢ LỜI NHANH
                        _buildGameCard(
                          title: 'Trả lời nhanh',
                          description: 'Thử thách phản xạ tiếng Trung',
                          assetPath: 'assets/images/icons/quick_answer_thumb.png',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0284C7), Color(0xFF0EA5E9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          onTap: onSelectQuickAnswer,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: GameBottomNavBar(
        currentIndex: 2,
        onTabSelected: (idx) {
          if (idx == 0) onBackToHome();
        },
      ),
    );
  }

  Widget _buildGameCard({
    required String title,
    required String description,
    required String assetPath,
    required Gradient gradient,
    required VoidCallback onTap,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 94,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.28), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                assetPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(child: Text('🎮', style: TextStyle(fontSize: 28))),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF7F0000),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFF1F5F9),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }
}
