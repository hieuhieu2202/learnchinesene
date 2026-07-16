import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../database/db_helper.dart';
import '../models/word.dart';
import '../models/example_sentence.dart';
import '../services/audio_service.dart';
import '../services/progress_service.dart';
import '../core/responsive/responsive_layout.dart';
import '../widgets/empty_state_widget.dart';
import 'speaking_screen.dart';
import '../features/hanzi_writing/screens/hanzi_writing_screen.dart';

class WordDetailScreen extends StatefulWidget {
  static const routeName = '/word-detail';
  const WordDetailScreen({super.key});
  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  final audio = AudioService();
  final progress = ProgressService();
  Word? word;
  Future<List<ExampleSentence>>? examples;
  bool learned = false;
  int? _characterId;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (word != null) return;
    final a =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    word = a?['word'] as Word?;
    if (word != null) {
      examples = DbHelper.instance.getExamplesByWord(word!.id);
      _checkCharacterWriting();
    }
  }

  Future<void> _checkCharacterWriting() async {
    if (word == null) return;
    final charId = await DbHelper.instance.getCharacterIdByCharString(word!.chinese);
    if (mounted) {
      setState(() {
        _characterId = charId;
      });
    }
  }

  @override
  void dispose() {
    audio.dispose();
    super.dispose();
  }

  void speak({int? exampleId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        child: SpeakingScreen(
          wordId: exampleId == null ? word?.id : null,
          exampleId: exampleId,
          isBottomSheet: true,
        ),
      ),
    );
  }

  Future<void> mark() async {
    await progress.markLearned(word!.id);
    if (mounted) setState(() => learned = true);
  }

  @override
  Widget build(BuildContext context) {
    final w = word;
    if (w == null)
      return const Scaffold(
        body: EmptyStateWidget(
          icon: Icons.search_off_rounded,
          title: 'Không tìm thấy từ',
          message: 'Từ vựng này hiện không khả dụng.',
        ),
      );
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chi tiết từ vựng',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: mark,
            icon: Icon(
              learned
                  ? Icons.bookmark_added_rounded
                  : Icons.bookmark_add_outlined,
              color: learned ? AppColors.success : null,
            ),
          ),
        ],
      ),
      body: Column(
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
                    24,
                  ),
                  children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.redDark,
                        AppColors.red,
                        AppColors.orange,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x30B4232C),
                        blurRadius: 25,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (w.sectionTitle.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            w.sectionTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 18),
                      Text(
                        w.chinese,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 58,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'FZKaiTiPinyin',
                          fontFamilyFallback: ['FZKaiTiPinyin_1', 'PingFang SC', 'Heiti SC', 'Microsoft YaHei', 'Noto Sans SC'],
                        ),
                      ),
                      Text(
                        w.vietnamese,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton.filled(
                            onPressed: w.ttsUrl.isEmpty
                                ? null
                                : () => audio.playUrl(w.ttsUrl),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.red,
                            ),
                            icon: const Icon(Icons.volume_up_rounded),
                          ),
                          const SizedBox(width: 12),
                          IconButton.filled(
                            onPressed: () => speak(),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.red,
                            ),
                            icon: const Icon(Icons.mic_rounded),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                const Text(
                  'Câu mẫu theo ngữ cảnh',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<ExampleSentence>>(
                  future: examples,
                  builder: (context, snap) {
                    if (!snap.hasData)
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    final data = snap.data!;
                    if (data.isEmpty)
                      return const EmptyStateWidget(
                        icon: Icons.chat_bubble_outline_rounded,
                        title: 'Chưa có câu mẫu',
                        message: 'Từ này chưa có câu ví dụ.',
                      );
                    return Column(
                      children: data.asMap().entries.map((entry) {
                        final e = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 11),
                          padding: const EdgeInsets.all(17),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFE9E5),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${entry.key + 1}',
                                  style: const TextStyle(
                                    color: AppColors.red,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.chinese,
                                      style: const TextStyle(
                                        fontSize: 22, // slightly bigger since it's kaiti
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'FZKaiTiPinyin',
                                        fontFamilyFallback: ['FZKaiTiPinyin_1', 'PingFang SC', 'Heiti SC', 'Microsoft YaHei', 'Noto Sans SC'],
                                      ),
                                    ),
                                    if (e.vietnamese.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Text(
                                          e.vietnamese,
                                          style: const TextStyle(
                                            color: AppColors.muted,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => speak(
                                  exampleId: e.id,
                                ),
                                icon: const Icon(
                                  Icons.mic_none_rounded,
                                  color: AppColors.red,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
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
              child: Row(
                children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => speak(),
                    icon: const Icon(Icons.record_voice_over_rounded),
                    label: const Text('Luyện phát âm'),
                  ),
                ),
                if (_characterId != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HanziWritingScreen(
                              characterId: _characterId!,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.draw_rounded),
                      label: const Text('Luyện viết'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.red),
                        foregroundColor: AppColors.red,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        ],
      ),
    );
  }
}
