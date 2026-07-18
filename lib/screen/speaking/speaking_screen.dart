import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/responsive/responsive_layout.dart';
import 'controller/speaking_controller.dart';

class SpeakingScreen extends StatelessWidget {
  final int? wordId;
  final int? exampleId;
  final int? unitId;
  final bool random;
  final bool isBottomSheet;

  const SpeakingScreen({
    super.key,
    this.wordId,
    this.exampleId,
    this.unitId,
    this.random = false,
    this.isBottomSheet = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SpeakingController(
      wordId: wordId,
      exampleId: exampleId,
      unitId: unitId,
      random: random,
      isBottomSheet: isBottomSheet,
    ));

    return Obx(() {
      Widget content;

      if (controller.isLoading.value) {
        content = const Center(child: CircularProgressIndicator());
      } else if (controller.errorMessage.value != null) {
        content = Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(controller.errorMessage.value!,
                  style: const TextStyle(color: AppColors.muted)),
            ],
          ),
        );
      } else {
        final item = controller.items[controller.currentIndex.value];
        content = Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveHelper.contentMaxWidth(context),
            ),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                ResponsiveHelper.horizontalPadding(context),
                controller.isBottomSheet ? 12 : 8,
                ResponsiveHelper.horizontalPadding(context),
                30,
              ),
              children: [
                if (controller.isBottomSheet)
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nghe và đọc lại',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.red,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    if (controller.items.length > 1)
                      Text(
                        '${controller.currentIndex.value + 1} / ${controller.items.length}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.muted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0C461419),
                        blurRadius: 24,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        item.targetText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: item.targetText.length > 8 ? 32 : 46,
                          height: 1.2,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'FZKaiTiPinyin',
                          fontFamilyFallback: const [
                            'FZKaiTiPinyin_1',
                            'PingFang SC',
                            'Heiti SC',
                            'Microsoft YaHei',
                            'Noto Sans SC',
                          ],
                        ),
                      ),
                      if (item.meaning.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          item.meaning,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                      if (item.audioUrl != null &&
                          item.audioUrl!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        IconButton(
                          onPressed: () =>
                              controller.audioService.playUrl(item.audioUrl!),
                          icon: const Icon(
                            Icons.volume_up_rounded,
                            color: AppColors.red,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFFFE9E5),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                Center(
                  child: ScaleTransition(
                    scale: controller.pulse,
                    child: InkWell(
                      onTap: controller.busy.value
                          ? null
                          : () => controller.start(context),
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 108,
                        height: 108,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.red, AppColors.orange],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x45B4232C),
                              blurRadius: 28,
                              offset: Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Icon(
                          controller.busy.value
                              ? Icons.graphic_eq_rounded
                              : Icons.mic_rounded,
                          size: 46,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  controller.busy.value
                      ? 'Đang nghe… hãy nói tự nhiên'
                      : 'Chạm micro để bắt đầu',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 30),
                if (controller.correct.value != null)
                  _resultCard(context, controller)
                else
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3EF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.tips_and_updates_outlined,
                          color: AppColors.orange,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Mẹo: hãy nói rõ ràng với tốc độ thoải mái. Bạn có thể thử lại bất cứ lúc nào.',
                            style: TextStyle(
                              color: AppColors.muted,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      }

      if (controller.isBottomSheet) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: content,
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Luyện phát âm',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: content,
      );
    });
  }

  Widget _resultCard(BuildContext context, SpeakingController controller) =>
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: controller.correct.value!
              ? const Color(0xFFE7F7F0)
              : const Color(0xFFFFE9E7),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: controller.correct.value!
                        ? AppColors.success
                        : AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${controller.score.value.round()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.correct.value!
                            ? 'Phát âm rất tốt!'
                            : 'Gần đúng rồi — thử lại nhé',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Đã nhận diện: ${controller.recognized.value.isEmpty ? 'Không nghe thấy giọng nói' : controller.recognized.value}',
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: controller.busy.value
                        ? null
                        : () => controller.start(context),
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('Luyện lại'),
                  ),
                ),
                if (controller.items.length > 1) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: controller.busy.value
                          ? null
                          : () => controller.nextItem(context),
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text(
                        controller.currentIndex.value <
                                controller.items.length - 1
                            ? 'Tiếp theo'
                            : 'Hoàn thành',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
}
