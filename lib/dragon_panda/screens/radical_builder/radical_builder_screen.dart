import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// REQUIRED ASSETS:
/// 1. Background: assets/images/backgrounds/radical_builder_bg.png
class RadicalBuilderScreen extends StatelessWidget {
  final VoidCallback onBack;

  const RadicalBuilderScreen({Key? key, required this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ==========================================
          // LAYER 0: PURE PEACEFUL CHINESE GARDEN BACKGROUND
          // REQUIRED ASSET: assets/images/backgrounds/radical_builder_bg.png
          // ==========================================
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgrounds/radical_builder_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // ==========================================
          // LAYER 1: FLUTTER GAMEPLAY UI
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
                        'Xây chữ Hán',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          shadows: [Shadow(color: Colors.black87, blurRadius: 6)],
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

                // Progress Bar: 6 / 10
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                  child: Row(
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 12,
                            color: Colors.black.withOpacity(0.35),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: 0.6,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    gradient: AppColors.orangeGoldGradient,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        '6 / 10',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Main Chinese Character Card (好)
                Container(
                  width: 230,
                  height: 230,
                  decoration: BoxDecoration(
                    color: AppColors.cardCream,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: AppColors.cardCreamBorder, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '好',
                      style: TextStyle(
                        fontSize: 105,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ),
                const Spacer(),

                // Radical / Component Selection Tray
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1FBF8).withOpacity(0.96),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['女', '子', '丿', '一'].map((radical) {
                      return GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF0F766E), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              radical,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
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
