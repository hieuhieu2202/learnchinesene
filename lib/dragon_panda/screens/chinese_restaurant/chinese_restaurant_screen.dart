import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// REQUIRED ASSETS:
/// 1. Background: assets/images/backgrounds/restaurant_bg.png
/// 2. Character:  assets/images/characters/panda_chef.png
/// 3. Foods:      assets/images/foods/noodles.png
///                assets/images/foods/rice.png
///                assets/images/foods/dumplings.png
class ChineseRestaurantScreen extends StatelessWidget {
  final VoidCallback onBack;

  const ChineseRestaurantScreen({Key? key, required this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ==========================================
          // LAYER 0: PURE RESTAURANT INTERIOR BACKGROUND
          // REQUIRED ASSET: assets/images/backgrounds/restaurant_bg.png
          // ==========================================
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgrounds/restaurant_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // ==========================================
          // LAYER 1: FLUTTER GAMEPLAY UI & PANDA CHEF
          // ==========================================
          SafeArea(
            child: Column(
              children: [
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.35), shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                          onPressed: onBack,
                        ),
                      ),
                      const Text(
                        'Nhà hàng Trung Hoa',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          shadows: [Shadow(color: Colors.black, blurRadius: 6)],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.35), shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white, size: 22),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),

                // Customer Speech Bubble
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: const [
                      Text(
                        '请给我一碗面。',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textDark),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '(Làm ơn cho tôi một bát mì.)',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),

                // Progress Indicator 4/10
                Container(
                  width: 140,
                  height: 10,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
                const Spacer(),

                // Panda Chef Behind Counter
                SizedBox(
                  width: 190,
                  height: 190,
                  child: Image.asset(
                    'assets/images/characters/panda_chef.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Center(child: Text('🐼🍜👨‍🍳', style: TextStyle(fontSize: 70))),
                  ),
                ),
                const Spacer(),

                // 3 Food Choice Cards Tray
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  decoration: BoxDecoration(
                    color: AppColors.cardCream,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, -4)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFoodCard('面', 'Mì', 'assets/images/foods/noodles.png', '🍜'),
                      _buildFoodCard('米饭', 'Cơm', 'assets/images/foods/rice.png', '🍚'),
                      _buildFoodCard('饺子', 'Sủi cảo', 'assets/images/foods/dumplings.png', '🥟'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCard(String hanzi, String vietnamese, String assetPath, String fallbackEmoji) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 100,
        height: 115,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryOrange, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 44,
              height: 44,
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Text(fallbackEmoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hanzi,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textDark),
            ),
            Text(
              vietnamese,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
