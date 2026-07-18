import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import 'controller/translator_controller.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final controller = Get.put(TranslatorController());

  void _showImageSourceSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Chọn nguồn ảnh dịch',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading:
                  const Icon(Icons.camera_alt_rounded, color: AppColors.red),
              title: const Text('Chụp ảnh mới',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Get.back();
                controller.pickAndTranslateImage(ImageSource.camera);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: AppColors.orange),
              title: const Text('Chọn từ thư viện',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Get.back();
                controller.pickAndTranslateImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Dịch thuật AI',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Input Area Card
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: controller.inputController,
                        maxLines: 4,
                        minLines: 2,
                        style:
                            const TextStyle(fontSize: 16, color: AppColors.ink),
                        decoration: InputDecoration(
                          hintText:
                              'Nhập tiếng Trung hoặc tiếng Việt cần dịch...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                              color: AppColors.muted.withOpacity(0.6)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _showImageSourceSheet,
                            icon: const Icon(Icons.photo_camera_rounded,
                                color: AppColors.muted),
                            tooltip: 'Dịch qua hình ảnh',
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () {
                              controller.inputController.clear();
                              controller.hasResult.value = false;
                            },
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            label: const Text('Xóa'),
                            style: TextButton.styleFrom(
                                foregroundColor: AppColors.muted),
                          ),
                          const SizedBox(width: 8),
                          Obx(() => controller.isLoading.value
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5),
                                )
                              : FilledButton(
                                  onPressed: controller.translateText,
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size(80, 44),
                                  ),
                                  child: const Text('Dịch'),
                                )),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),

            // Translation Results Area
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!controller.hasResult.value) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40.0, vertical: 60.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.g_translate_rounded,
                            size: 80,
                            color: AppColors.muted.withOpacity(0.2),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Sẵn sàng dịch thuật',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Hỗ trợ dịch hai chiều Trung - Việt, tự động phân tích pinyin, ví dụ thực tế và ngữ pháp đi kèm.',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: AppColors.muted, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Translation Result Card
                      Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${controller.sourceLang.value} ➔ ${controller.targetLang.value}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.red,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () => controller
                                        .speak(controller.hanzi.value),
                                    icon: const Icon(Icons.volume_up_rounded,
                                        color: AppColors.red),
                                    tooltip: 'Phát âm chữ Hán',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Chinese text
                              SelectableText(
                                controller.hanzi.value,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                  fontFamily: 'FZKaiTiPinyin',
                                ),
                              ),
                              if (controller.pinyin.value.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                SelectableText(
                                  controller.pinyin.value,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.orange,
                                  ),
                                ),
                              ],
                              const Divider(height: 32),
                              const Text(
                                'Bản dịch nghĩa',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.muted,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SelectableText(
                                controller.viMeaning.value,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.45,
                                  color: AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Example Sentences Card
                      if (controller.examples.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'Ví dụ minh họa',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink),
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: controller.examples.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 24),
                            itemBuilder: (context, index) {
                              final ex = controller.examples[index];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: SelectableText(
                                          ex['zh'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.ink,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: () =>
                                            controller.speak(ex['zh'] ?? ''),
                                        icon: const Icon(
                                            Icons.volume_up_rounded,
                                            size: 20,
                                            color: AppColors.muted),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  SelectableText(
                                    ex['pinyin'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.orange,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  SelectableText(
                                    ex['vi'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],

                      // Grammar Notes Card
                      if (controller.grammarNotes.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'Điểm ngữ pháp & Từ vựng',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink),
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.only(bottom: 32),
                          color: AppColors.orange.withOpacity(0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                            side: BorderSide(
                                color: AppColors.orange.withOpacity(0.15)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: controller.grammarNotes.map((note) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding:
                                            EdgeInsets.only(top: 4, right: 10),
                                        child: Icon(Icons.lightbulb_rounded,
                                            size: 18, color: AppColors.orange),
                                      ),
                                      Expanded(
                                        child: SelectableText(
                                          note,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            height: 1.45,
                                            color: AppColors.ink,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
