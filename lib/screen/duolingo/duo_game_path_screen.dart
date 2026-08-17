import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/duo_game_path_controller.dart';
import 'view/duo_stage_node.dart';
import 'duo_game_runner_screen.dart';

class DuoGamePathScreen extends StatefulWidget {
  final int gameId;
  final String gameCode;
  final String gameName;
  final String description;

  const DuoGamePathScreen({
    super.key,
    required this.gameId,
    required this.gameCode,
    required this.gameName,
    required this.description,
  });

  @override
  State<DuoGamePathScreen> createState() => _DuoGamePathScreenState();
}

class _DuoGamePathScreenState extends State<DuoGamePathScreen> {
  late final DuoGamePathController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(DuoGamePathController(gameId: widget.gameId, gameCode: widget.gameCode), tag: widget.gameId.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(widget.gameName),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.levels.isEmpty) {
          return const Center(child: Text('Không tìm thấy lộ trình của game này.'));
        }

        // Tối ưu hóa cực lớn cho danh sách lên đến 1500+ cấp độ bằng cách sử dụng CustomScrollView + SliverList
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Header trò chơi
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getGameIcon(widget.gameCode),
                        color: Colors.blue,
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.gameName.toUpperCase(),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Text(
                        widget.description,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'TỔNG SỐ: ${controller.levels.length} MÀN CHƠI',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade700, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // 2. Lộ trình cấp độ bằng SliverList
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, idx) {
                  final level = controller.levels[idx];
                  final levelId = level['level_id'] as String;
                  final secNum = level['section_number'] as int;
                  final secTitle = level['section_title'] as String;
                  final unitNum = level['unit_number'] as int;
                  final unitTitle = level['unit_title'] as String;
                  final levelIndex = level['level_index'] as int;
                  final cCount = level['challenge_count'] as int;
                  final isUnlocked = level['is_unlocked'] as int == 1;
                  final isCompleted = level['is_completed'] as int == 1;
                  final stars = level['stars'] as int;

                  bool showSectionHeader = false;
                  bool showUnitHeader = false;

                  if (idx == 0) {
                    showSectionHeader = true;
                    showUnitHeader = true;
                  } else {
                    final prev = controller.levels[idx - 1];
                    if (prev['section_title'] != secTitle) {
                      showSectionHeader = true;
                      showUnitHeader = true;
                    } else if (prev['unit_title'] != unitTitle) {
                      showUnitHeader = true;
                    }
                  }

                  // Tính vị trí zigzag cho node
                  double offset = 0;
                  if (idx % 4 == 1) offset = -50;
                  if (idx % 4 == 3) offset = 50;

                  String status = 'locked';
                  if (cCount == 0) {
                    status = 'locked'; // Empty level
                  } else if (isCompleted) {
                    status = 'completed';
                  } else if (isUnlocked) {
                    status = 'available';
                  }

                  return Column(
                    children: [
                      if (showSectionHeader)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 24, bottom: 8),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          color: Colors.blue.shade800,
                          child: Text(
                            'PHẦN $secNum: $secTitle'.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      if (showUnitHeader)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 8, bottom: 16, left: 16, right: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Text(
                            'Chương $unitNum: $unitTitle',
                            style: TextStyle(color: Colors.blue.shade900, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      if (idx > 0 && !showSectionHeader && !showUnitHeader)
                        Container(
                          width: 4,
                          height: 30,
                          color: (isUnlocked && cCount > 0) ? Colors.blue.shade300 : Colors.grey.shade300,
                        ),
                      Opacity(
                        opacity: cCount == 0 ? 0.4 : 1.0,
                        child: Transform.translate(
                          offset: Offset(offset, 0),
                          child: DuoStageNode(
                            stageNumber: levelIndex + 1,
                            nameVi: cCount == 0 ? 'Trống' : 'Cấp độ ${levelIndex + 1}',
                            icon: _getEmojiIcon(widget.gameCode),
                            status: status,
                            stars: stars,
                            onTap: () {
                              if (cCount == 0) {
                                Get.snackbar('Trống', 'Chưa có thử thách nào cho game này ở cấp độ này.');
                                return;
                              }
                              if (!isUnlocked) {
                                Get.snackbar('Khóa', 'Bạn cần vượt qua các cấp độ trước.');
                                return;
                              }
                              Get.to(() => DuoGameRunnerScreen(
                                gameId: widget.gameId,
                                gameCode: widget.gameCode,
                                levelId: levelId,
                                gameName: widget.gameName,
                              ))?.then((_) => controller.loadLevels());
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
                childCount: controller.levels.length,
              ),
            ),
            
            // Padding cuối màn hình
            const SliverToBoxAdapter(
              child: SizedBox(height: 48),
            ),
          ],
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

  String _getEmojiIcon(String code) {
    switch (code) {
      case 'learn_words':
        return '🧠';
      case 'word_connect':
        return '🔗';
      case 'select_answer':
        return '🎯';
      case 'listen_select':
        return '🎧';
      case 'translate':
        return '🇨🇳';
      case 'gap_fill':
        return '✏️';
      case 'tap_complete':
        return '🧩';
      case 'dialogue':
        return '💬';
      case 'sentence_order':
        return '🔀';
      case 'speaking':
        return '🗣️';
      default:
        return '🎮';
    }
  }
}
