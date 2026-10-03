import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/game_button.dart';
import '../../widgets/stat_pill.dart';
import '../../widgets/bottom_navigation.dart';

/// REQUIRED ASSETS:
/// 1. Background: assets/images/backgrounds/home_bg.png
/// 2. Characters: assets/images/characters/panda_avatar.png
///                assets/images/characters/panda_archer.png
class HomeScreen extends StatelessWidget {
  final VoidCallback onNavigateToGameHub;

  const HomeScreen({Key? key, required this.onNavigateToGameHub}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ==========================================
          // LAYER 0: PURE BACKGROUND ART (NO UI)
          // REQUIRED ASSET: assets/images/backgrounds/home_bg.png
          // ==========================================
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgrounds/home_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // Subtle gradient overlay to enhance text readability at the top & bottom
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.35),
                    Colors.transparent,
                    Colors.black.withOpacity(0.55),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // ==========================================
          // LAYER 1: FLUTTER UI & OVERLAYS
          // ==========================================
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. TOP HEADER (Avatar Panda, Lời chào, Setting, Notification)
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryGold,
                                shape: BoxShape.circle,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.asset(
                                'assets/images/characters/panda_avatar.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Xin chào!',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(0, 1.5)),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Tiếp tục hành trình học tiếng Trung nào!',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFF1F5F9),
                                      shadows: [
                                        Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(0, 1)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.35), shape: BoxShape.circle),
                              child: IconButton(
                                icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 22),
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.35), shape: BoxShape.circle),
                              child: IconButton(
                                icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // 2. STATS ROW (7 Ngày học, 12 Bài học, 156 Điểm XP)
                        Row(
                          children: const [
                            StatPill(emoji: '🔥', count: '7', label: 'Ngày học', color: AppColors.primaryOrange),
                            SizedBox(width: 10),
                            StatPill(emoji: '📖', count: '12', label: 'Bài học', color: AppColors.successGreen),
                            SizedBox(width: 10),
                            StatPill(emoji: '⭐', count: '156', label: 'Điểm XP', color: AppColors.primaryGold),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // 3. HERO HERO AREA (Panda Warrior & Button)
                        SizedBox(
                          height: 240,
                          width: double.infinity,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Character Foreground Overlay
                              Positioned(
                                top: 0,
                                bottom: 60,
                                child: Image.asset(
                                  'assets/images/characters/panda_archer.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              // Button "Tiếp tục học >"
                              Positioned(
                                bottom: 6,
                                left: 20,
                                right: 20,
                                child: GameButton(
                                  text: 'Tiếp tục học >',
                                  gradient: AppColors.orangeGoldGradient,
                                  height: 54,
                                  borderRadius: 22,
                                  onTap: onNavigateToGameHub,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 4. QUICK ACTION GRID (6 Buttons)
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.05,
                          children: [
                            _buildActionCard(Icons.menu_book_rounded, 'Học từ vựng', AppColors.primaryOrange, () {}),
                            _buildActionCard(Icons.headphones_rounded, 'Luyện nghe', Colors.purple, () {}),
                            _buildActionCard(Icons.mic_rounded, 'Luyện nói', Colors.teal, () {}),
                            _buildActionCard(Icons.sports_esports_rounded, 'Trò chơi', Colors.deepOrange, onNavigateToGameHub),
                            _buildActionCard(Icons.emoji_events_rounded, 'Thử thách', AppColors.primaryGold, () {}),
                            _buildActionCard(Icons.storefront_rounded, 'Cửa hàng', AppColors.dangerRed, () {}),
                          ],
                        ),
                        const SizedBox(height: 10),
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
        currentIndex: 0,
        onTabSelected: (idx) {
          if (idx == 2) onNavigateToGameHub();
        },
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
