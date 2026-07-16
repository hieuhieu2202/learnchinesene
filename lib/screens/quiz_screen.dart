import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/quiz_question.dart';
import '../models/word.dart';
import '../core/responsive/responsive_layout.dart';
import '../services/audio_service.dart';
import '../services/progress_service.dart';
import '../services/quiz_service.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/primary_button.dart';
import '../widgets/quiz_option_button.dart';
import 'review_screen.dart';

class QuizScreen extends StatefulWidget {
  static const routeName = '/quiz';
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final quiz = QuizService();
  final progress = ProgressService();
  final audio = AudioService();
  int unitId = 0, index = 0, score = 0;
  String title = 'Bài học';
  List<Word> reviewWords = [];
  List<QuizQuestion> questions = [];
  String? selected;
  bool loading = true, initialized = false, complete = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (initialized) return;
    initialized = true;
    final a =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    unitId = (a?['unitId'] as int?) ?? 0;
    title = '${a?['unitTitle'] ?? 'Bài học'}';
    reviewWords = (a?['reviewWords'] as List<Word>?) ?? [];
    load();
  }

  @override
  void dispose() {
    audio.dispose();
    super.dispose();
  }

  Future<void> load() async {
    final q = reviewWords.isNotEmpty
        ? await quiz.generateForWords(reviewWords)
        : await quiz.generateForUnit(unitId);
    if (mounted)
      setState(() {
        questions = q;
        loading = false;
        index = 0;
        score = 0;
        selected = null;
        complete = false;
      });
  }

  Future<void> choose(QuizQuestion q, String value) async {
    if (selected != null) return;
    final correct = value == q.correctAnswer;
    setState(() {
      selected = value;
      if (correct) score++;
    });
    await progress.submitAnswer(wordId: q.wordId, isCorrect: correct);
  }

  void next() {
    if (index + 1 == questions.length) {
      setState(() => complete = true);
    } else {
      setState(() {
        index++;
        selected = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        complete ? 'Hoàn thành bài học' : 'Luyện tập nhanh',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : questions.isEmpty
        ? const EmptyStateWidget(
            icon: Icons.quiz_outlined,
            title: 'Chưa đủ từ để kiểm tra',
            message: 'Hoạt động này cần ít nhất bốn đáp án khác nhau.',
          )
        : complete
        ? _result()
        : _question(questions[index]),
  );
  Widget _question(QuizQuestion q) => Column(
    children: [
      Expanded(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: ResponsiveHelper.contentMaxWidth(context)),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                ResponsiveHelper.horizontalPadding(context),
                4,
                ResponsiveHelper.horizontalPadding(context),
                20,
              ),
              children: [
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: (index + 1) / questions.length,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${index + 1}/${questions.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              _label(q.type),
              style: const TextStyle(
                color: AppColors.red,
                fontSize: 12,
                letterSpacing: 1,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              q.question,
              style: const TextStyle(
                fontSize: 25,
                height: 1.3,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (q.type == QuizType.listening) ...[
              const SizedBox(height: 18),
              Center(
                child: InkWell(
                  onTap: () => audio.playUrl(q.audioUrl ?? ''),
                  borderRadius: BorderRadius.circular(40),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.red, AppColors.orange],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.volume_up_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 26),
            ...q.options.asMap().entries.map((e) {
              final state = selected == null
                  ? QuizOptionState.idle
                  : e.value == q.correctAnswer
                  ? QuizOptionState.correct
                  : selected == e.value
                  ? QuizOptionState.wrong
                  : QuizOptionState.idle;
              return Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: QuizOptionButton(
                  text: e.value,
                  index: e.key,
                  state: state,
                  enabled: selected == null,
                  onPressed: () => choose(q, e.value),
                ),
              );
            }),
            if (selected != null)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: selected == q.correctAnswer
                      ? const Color(0xFFE7F7F0)
                      : const Color(0xFFFFE9E7),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Icon(
                      selected == q.correctAnswer
                          ? Icons.celebration_rounded
                          : Icons.lightbulb_rounded,
                      color: selected == q.correctAnswer
                          ? AppColors.success
                          : AppColors.error,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selected == q.correctAnswer
                            ? 'Xuất sắc! Bạn đã trả lời đúng.'
                            : 'Đáp án đúng là ${q.correctAnswer}.',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
          ],
            ),
          ),
        ),
      ),
      if (selected != null)
        _bottom(
          PrimaryButton(
            label: index + 1 == questions.length
                ? 'Xem kết quả'
                : 'Câu tiếp theo',
            onPressed: next,
          ),
        ),
    ],
  );
  Widget _result() {
    final percent = (score / questions.length * 100).round();
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: ResponsiveHelper.contentMaxWidth(context)),
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.horizontalPadding(context),
            vertical: 24,
          ),
          children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.redDark, AppColors.red, AppColors.orange],
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                size: 58,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                '$percent%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Đúng $score/${questions.length} câu',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          percent >= 80
              ? '太棒了! Bạn làm rất tốt.'
              : 'Cố gắng tốt lắm — luyện tập sẽ giúp bạn tiến bộ.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        const Text(
          'Mỗi câu trả lời đều giúp ghi nhớ tốt hơn. Hãy tiếp tục nhé!',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, height: 1.5),
        ),
        const SizedBox(height: 28),
        PrimaryButton(
          label: 'Làm lại',
          icon: Icons.replay_rounded,
          onPressed: load,
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () =>
              Navigator.pushReplacementNamed(context, ReviewScreen.routeName),
          icon: const Icon(Icons.fact_check_outlined),
          label: const Text('Ôn lại câu sai'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
        ),
      ),
    );
  }

  Widget _bottom(Widget child) => Container(
    alignment: Alignment.center,
    padding: EdgeInsets.fromLTRB(
      ResponsiveHelper.horizontalPadding(context),
      12,
      ResponsiveHelper.horizontalPadding(context),
      12 + MediaQuery.paddingOf(context).bottom,
    ),
    decoration: const BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 16,
          offset: Offset(0, -4),
        ),
      ],
    ),
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: ResponsiveHelper.contentMaxWidth(context)),
      child: child,
    ),
  );
  String _label(QuizType t) => switch (t) {
    QuizType.listening => 'NGHE HIỂU',
    QuizType.chineseToPinyin => 'PINYIN',
    _ => 'NGHĨA CỦA TỪ',
  };
}
