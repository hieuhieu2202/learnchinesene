import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/duo_game_center_controller.dart';
import 'duo_game_path_screen.dart';

class DuoGameCenterScreen extends StatefulWidget {
  const DuoGameCenterScreen({super.key});

  @override
  State<DuoGameCenterScreen> createState() => _DuoGameCenterScreenState();
}

class _DuoGameCenterScreenState extends State<DuoGameCenterScreen> {
  final controller = Get.put(DuoGameCenterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Center'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.games.isEmpty) {
          return const Center(child: Text('Không tìm thấy dữ liệu trò chơi.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: controller.games.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, idx) {
            final game = controller.games[idx];
            final gameId = game['id'] as int;
            final gameCode = game['game_code'] as String;
            final nameVi = game['name_vi'] as String;
            final descVi = game['description_vi'] as String;
            final totalLevels = game['total_levels'] as int;
            final completedLevels = game['completed_levels'] as int;
            final bestStars = game['best_stars'] as int? ?? 0;

            final IconData iconData = _getGameIcon(gameCode);
            final Color gameColor = _getGameColor(gameCode);

            return Card(
              elevation: 4,
              shadowColor: gameColor.withValues(alpha: 0.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: InkWell(
                onTap: () {
                  Get.to(() => DuoGamePathScreen(
                    gameId: gameId,
                    gameCode: gameCode,
                    gameName: nameVi,
                    description: descVi,
                  ))?.then((_) => controller.loadGames());
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: gameColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(iconData, color: gameColor, size: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nameVi.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  descVi,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tiến trình: $completedLevels / $totalLevels Cấp độ',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          if (bestStars > 0)
                            Row(
                              children: List.generate(3, (starIdx) {
                                return Icon(
                                  starIdx < bestStars ? Icons.star_rounded : Icons.star_border_rounded,
                                  color: Colors.amber,
                                  size: 18,
                                );
                              }),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: totalLevels > 0 ? (completedLevels / totalLevels) : 0,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                          color: gameColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  IconData _getGameIcon(String code) {
    switch (code) {
      case 'learn_words':
        return Icons.psychology;
      case 'word_connect':
        return Icons.link;
      case 'select_answer':
        return Icons.adjust;
      case 'listen_select':
        return Icons.headphones;
      case 'translate':
        return Icons.translate;
      case 'gap_fill':
        return Icons.edit;
      case 'tap_complete':
        return Icons.extension;
      case 'dialogue':
        return Icons.chat_bubble;
      case 'sentence_order':
        return Icons.shuffle;
      case 'speaking':
        return Icons.mic;
      default:
        return Icons.videogame_asset;
    }
  }

  Color _getGameColor(String code) {
    switch (code) {
      case 'learn_words':
        return Colors.green;
      case 'word_connect':
        return Colors.blue;
      case 'select_answer':
        return Colors.orange;
      case 'listen_select':
        return Colors.purple;
      case 'translate':
        return Colors.red;
      case 'gap_fill':
        return Colors.teal;
      case 'tap_complete':
        return Colors.indigo;
      case 'dialogue':
        return Colors.pink;
      case 'sentence_order':
        return Colors.cyan;
      case 'speaking':
        return Colors.amber.shade800;
      default:
        return Colors.blueGrey;
    }
  }
}
