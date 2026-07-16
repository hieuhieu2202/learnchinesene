import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../database/db_helper.dart';
import '../models/word.dart';
import '../services/progress_service.dart';
import '../widgets/empty_state_widget.dart';
import '../core/responsive/responsive_layout.dart';
import '../widgets/primary_button.dart';
import '../widgets/word_card.dart';
import 'quiz_screen.dart';
import 'word_detail_screen.dart';

class WordListScreen extends StatefulWidget {
  static const routeName = '/words';
  const WordListScreen({super.key});
  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  final controller = PageController(viewportFraction: .92);
  final progress = ProgressService();
  Future<List<Word>>? future;
  int unitId = 0;
  String title = 'Từ vựng';
  int index = 0;
  bool loaded = false;
  final learned = <int>{};
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (loaded) return;
    loaded = true;
    final a =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    unitId = (a?['unitId'] as int?) ?? 0;
    title = '${a?['unitTitle'] ?? 'Từ vựng'}';
    future = DbHelper.instance.getWordsByUnit(unitId);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> mark(Word word) async {
    await progress.markLearned(word.id);
    if (mounted) setState(() => learned.add(word.id));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_horiz_rounded),
        ),
      ],
    ),
    body: FutureBuilder<List<Word>>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done)
          return const Center(child: CircularProgressIndicator());
        if (snap.hasError)
          return const EmptyStateWidget(
            icon: Icons.error_outline_rounded,
            title: 'Không thể tải bài học',
            message: 'Không thể mở bài từ vựng ngoại tuyến này.',
          );
        final words = snap.data ?? [];
        if (words.isEmpty)
          return const EmptyStateWidget(
            icon: Icons.style_outlined,
            title: 'Chưa có từ vựng',
            message: 'Bài học này chưa có dữ liệu từ vựng.',
          );
        final current = words[index.clamp(0, words.length - 1)];
        return Column(
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: ResponsiveHelper.contentMaxWidth(context)),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: (index + 1) / words.length,
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${index + 1} / ${words.length}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: PageView.builder(
                          controller: controller,
                          itemCount: words.length,
                          onPageChanged: (i) => setState(() => index = i),
                          itemBuilder: (context, i) => Padding(
                            padding: const EdgeInsets.fromLTRB(5, 5, 5, 14),
                            child: WordCard(
                              hero: true,
                              word: words[i],
                              onTap: () => Navigator.pushNamed(
                                context,
                                WordDetailScreen.routeName,
                                arguments: {'word': words[i]},
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(
                ResponsiveHelper.horizontalPadding(context),
                14,
                ResponsiveHelper.horizontalPadding(context),
                14 + MediaQuery.paddingOf(context).bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 18,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: ResponsiveHelper.contentMaxWidth(context)),
                child: Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: learned.contains(current.id)
                          ? null
                          : () => mark(current),
                      icon: Icon(
                        learned.contains(current.id)
                            ? Icons.check_rounded
                            : Icons.bookmark_add_outlined,
                      ),
                      tooltip: 'Đánh dấu đã học',
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        label: index == words.length - 1
                            ? 'Kiểm tra bài học'
                            : 'Từ tiếp theo',
                        icon: index == words.length - 1
                            ? Icons.quiz_rounded
                            : Icons.arrow_forward_rounded,
                        onPressed: () {
                          if (index == words.length - 1) {
                            Navigator.pushNamed(
                              context,
                              QuizScreen.routeName,
                              arguments: {'unitId': unitId, 'unitTitle': title},
                            );
                          } else {
                            controller.nextPage(
                              duration: const Duration(milliseconds: 320),
                              curve: Curves.easeOutCubic,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
