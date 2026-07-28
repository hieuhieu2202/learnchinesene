import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/primary_button.dart';
import 'controller/hsk_exam_controller.dart';

class HskExamScreen extends StatefulWidget {
  const HskExamScreen({super.key});

  @override
  State<HskExamScreen> createState() => _HskExamScreenState();
}

class _HskExamScreenState extends State<HskExamScreen> {
  final controller = Get.put(HskExamController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Thi thử HSK với AI',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          Obx(() {
            if (controller.examState.value == 'started') {
              return TextButton(
                onPressed: controller.submitExam,
                child: const Text('Nộp bài',
                    style: TextStyle(
                        color: AppColors.red, fontWeight: FontWeight.bold)),
              );
            }
            if (controller.examState.value == 'submitted') {
              return TextButton(
                onPressed: controller.reset,
                child: const Text('Làm lại',
                    style: TextStyle(color: AppColors.red)),
              );
            }
            return const SizedBox();
          })
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final state = controller.examState.value;

          if (state == 'loading') {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang khởi tạo đề thi thử...',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: AppColors.muted)),
                ],
              ),
            );
          }

          if (state == 'submitting') {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('AI đang chấm điểm và đánh giá...',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: AppColors.muted)),
                ],
              ),
            );
          }

          if (state == 'notStarted') {
            return _buildStartScreen();
          }

          if (state == 'submitted') {
            return _buildResultScreen();
          }

          return _buildExamScreen();
        }),
      ),
    );
  }

  Widget _buildStartScreen() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.quiz_rounded, size: 90, color: AppColors.red),
          const SizedBox(height: 20),
          const Text(
            'Luyện thi HSK thông minh',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.ink),
          ),
          const SizedBox(height: 12),
          const Text(
            'Đề thi được tạo ngẫu nhiên dựa trên chuẩn HSK. Sau khi nộp bài, bạn sẽ nhận được đánh giá chi tiết điểm mạnh, điểm yếu và lộ trình cải thiện từ giáo viên AI.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, height: 1.45),
          ),
          const SizedBox(height: 40),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Text('Chọn cấp độ HSK:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 20),
                  Expanded(
                    child: DropdownButton<int>(
                      value: controller.selectedLevel.value,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: List.generate(6, (index) {
                        final lvl = index + 1;
                        return DropdownMenuItem(
                          value: lvl,
                          child: Text('HSK $lvl',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        );
                      }),
                      onChanged: (val) {
                        if (val != null) {
                          controller.selectedLevel.value = val;
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          PrimaryButton(
            label: 'Bắt đầu làm bài',
            onPressed: controller.generateExam,
          ),
        ],
      ),
    );
  }

  Widget _buildExamScreen() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: AppColors.orange.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          alignment: Alignment.center,
          child: Text(
            'Bài thi HSK ${controller.selectedLevel.value} - Số câu: ${controller.questions.length}',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.orange),
          ),
        ),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: controller.questions.length,
            itemBuilder: (context, index) {
              final q = controller.questions[index];
              final section = q['section'] ?? '';
              final isListening = section == 'Nghe hiểu';
              final options = q['options'] as List<String>? ?? [];
              final userAns = controller.userAnswers[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Câu ${index + 1} ($section)',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.red),
                            ),
                          ),
                          if (isListening && q['audio_script'] != null) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () =>
                                  controller.speak(q['audio_script']),
                              icon: const Icon(Icons.volume_up_rounded,
                                  color: AppColors.red),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        q['question_text'] ?? '',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink),
                      ),
                      const SizedBox(height: 16),
                      // Options list
                      ...options.map((opt) {
                        final isSelected = userAns == opt;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () =>
                                controller.selectOption(index, opt),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? AppColors.red.withOpacity(0.08)
                                  : Colors.white,
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.red
                                    : AppColors.muted.withOpacity(0.2),
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              alignment: Alignment.centerLeft,
                            ),
                            child: Text(
                              opt,
                              style: TextStyle(
                                color:
                                    isSelected ? AppColors.red : AppColors.ink,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResultScreen() {
    final pct =
        (controller.score.value / controller.questions.length * 100).round();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Score summary card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text('KẾT QUẢ BÀI THI',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.muted)),
                  const SizedBox(height: 12),
                  Text(
                    '${controller.score.value}/${controller.questions.length}',
                    style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: AppColors.red),
                  ),
                  Text('Độ chính xác: $pct%',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink)),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: controller.score.value / controller.questions.length,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Detailed AI review
          if (controller.analysisLoading.value)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Đang tải phản hồi từ giáo viên AI...',
                        style: TextStyle(color: AppColors.muted)),
                  ],
                ),
              ),
            )
          else ...[
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'Đánh giá từ Giáo viên AI',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (controller.overallAssessment.value.isNotEmpty) ...[
                      const Text('Nhận xét tổng quan:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.orange)),
                      const SizedBox(height: 6),
                      Text(controller.overallAssessment.value,
                          style: const TextStyle(
                              height: 1.45, color: AppColors.ink)),
                      const Divider(height: 32),
                    ],
                    if (controller.strengths.isNotEmpty) ...[
                      const Text('Điểm mạnh của bạn:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.success)),
                      const SizedBox(height: 6),
                      ...controller.strengths.map((str) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle_rounded,
                                    size: 18, color: AppColors.success),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(str,
                                        style: const TextStyle(
                                            color: AppColors.ink))),
                              ],
                            ),
                          )),
                      const Divider(height: 32),
                    ],
                    if (controller.weaknesses.isNotEmpty) ...[
                      const Text('Điểm cần cải thiện:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.error)),
                      const SizedBox(height: 6),
                      ...controller.weaknesses.map((weak) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.warning_amber_rounded,
                                    size: 18, color: AppColors.error),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(weak,
                                        style: const TextStyle(
                                            color: AppColors.ink))),
                              ],
                            ),
                          )),
                      const Divider(height: 32),
                    ],
                    if (controller.studySuggestions.isNotEmpty) ...[
                      const Text('Gợi ý học tập:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.red)),
                      const SizedBox(height: 6),
                      ...controller.studySuggestions.map((sug) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.lightbulb_rounded,
                                    size: 18, color: AppColors.orange),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(sug,
                                        style: const TextStyle(
                                            color: AppColors.ink))),
                              ],
                            ),
                          )),
                    ],
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Xem chi tiết đáp án',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink),
            ),
          ),

          // Detail Answers review list
          ...List.generate(controller.questions.length, (index) {
            final q = controller.questions[index];
            final userAns = controller.userAnswers[index];
            final correct = q['correct_answer'];
            final isCorrect = userAns?.trim().toLowerCase() ==
                correct.toString().trim().toLowerCase();

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Câu ${index + 1}: ',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Icon(
                          isCorrect
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          color:
                              isCorrect ? AppColors.success : AppColors.error,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(q['question_text'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text('Đáp án của bạn: ${userAns ?? "Chưa trả lời"}',
                        style: TextStyle(
                            color: isCorrect
                                ? AppColors.success
                                : AppColors.error)),
                    Text('Đáp án đúng: $correct',
                        style: const TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold)),
                    const Divider(height: 20),
                    Text('Giải thích: ${q['explanation']}',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.muted)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
