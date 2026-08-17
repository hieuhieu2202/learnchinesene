import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import 'controller/duo_flashcard_controller.dart';

class DuoFlashcardScreen extends StatefulWidget {
  const DuoFlashcardScreen({super.key});

  @override
  State<DuoFlashcardScreen> createState() => _DuoFlashcardScreenState();
}

class _DuoFlashcardScreenState extends State<DuoFlashcardScreen> {
  final controller = Get.put(DuoFlashcardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Học Từ Vựng')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.flashcards.isEmpty) {
          return const Center(child: Text('Không tìm thấy từ vựng'));
        }

        final flashcard = controller.flashcards[controller.currentIndex.value];

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text('Từ ${controller.currentIndex.value + 1} / ${controller.flashcards.length}', 
                   style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 20),
              Expanded(
                child: GestureDetector(
                  onTap: controller.toggleMeaning,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          flashcard.word,
                          style: TextStyle(
                            fontSize: 80, 
                            fontWeight: FontWeight.bold, 
                            fontFamily: controller.showMeaning.value ? 'FZKaiTiPinyin' : null,
                          ),
                        ),
                        if (controller.showMeaning.value) ...[
                          const SizedBox(height: 20),
                          Text(
                            flashcard.meaning ?? '',
                            style: const TextStyle(fontSize: 24, color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                        ] else ...[
                          const SizedBox(height: 40),
                          const Text('Chạm để xem nghĩa', style: TextStyle(color: Colors.grey)),
                        ]
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: controller.nextCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Tiếp Theo', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        );
      }),
    );
  }
}
