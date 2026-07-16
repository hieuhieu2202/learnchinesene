import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../database/db_helper.dart';
import '../models/speaking_practice_item.dart';
import '../services/speech_service.dart';
import '../services/vocabulary_service.dart';
import '../services/audio_service.dart';
import '../core/responsive/responsive_layout.dart';
import '../widgets/pinyin_text.dart';

class SpeakingScreen extends StatefulWidget {
  static const routeName = '/speaking';
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
  State<SpeakingScreen> createState() => _SpeakingScreenState();
}

class _SpeakingScreenState extends State<SpeakingScreen>
    with SingleTickerProviderStateMixin {
  final speech = SpeechService();
  final vocabService = VocabularyService();
  final audioService = AudioService();

  List<SpeakingPracticeItem> items = [];
  int currentIndex = 0;
  bool isLoading = true;
  String? errorMessage;

  bool busy = false;
  String recognized = '';
  double score = 0;
  bool? correct;
  late final AnimationController pulse;

  @override
  void initState() {
    super.initState();
    pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: .92,
      upperBound: 1.08,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      List<SpeakingPracticeItem> loaded = [];
      
      bool isRandom = widget.random;
      int? wId = widget.wordId;
      int? eId = widget.exampleId;
      int? uId = widget.unitId;
      
      // Default to random if no arguments are passed
      if (wId == null && eId == null && uId == null && !isRandom) {
        isRandom = true;
      }

      if (wId != null) {
        final item = await vocabService.getSpeakingItemByWordId(wId);
        if (item != null) loaded.add(item);
      } else if (eId != null) {
        final item = await vocabService.getSpeakingItemByExampleId(eId);
        if (item != null) loaded.add(item);
      } else if (uId != null) {
        loaded = await vocabService.getSpeakingItemsByUnitId(uId);
      } else if (isRandom) {
        loaded = await vocabService.getRandomSpeakingItems();
      }

      if (mounted) {
        setState(() {
          items = loaded;
          isLoading = false;
          if (items.isEmpty) {
            errorMessage = 'Không có dữ liệu luyện tập.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Lỗi tải dữ liệu: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    pulse.dispose();
    speech.stop();
    audioService.dispose();
    super.dispose();
  }

  Future<void> start() async {
    if (items.isEmpty) return;
    
    if (!await speech.ensureMicPermission()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng cấp quyền micro để luyện phát âm.'),
          ),
        );
      }
      return;
    }
    
    final currentItem = items[currentIndex];
    
    setState(() {
      busy = true;
      recognized = '';
      correct = null;
    });
    pulse.repeat(reverse: true);
    
    final result = await speech.listenAndScore(targetText: currentItem.targetText);
    
    pulse.stop();
    pulse.value = 1;
    
    if (!result.isAvailable) {
      if (mounted) setState(() => busy = false);
      return;
    }

    if (currentItem.wordId != null || currentItem.exampleId != null) {
      await DbHelper.instance.saveSpeakingPractice(
        wordId: currentItem.wordId ?? 0,
        exampleId: currentItem.exampleId,
        targetText: currentItem.targetText,
        recognizedText: result.recognizedText,
        score: result.score,
        isCorrect: result.isCorrect,
      );
    }
    
    if (currentItem.wordId != null) {
      await DbHelper.instance.upsertProgress(
        wordId: currentItem.wordId!,
        isCorrect: result.isCorrect,
      );
    }

    if (mounted) {
      setState(() {
        busy = false;
        recognized = result.recognizedText;
        score = result.score;
        correct = result.isCorrect;
      });
    }
  }
  
  void nextItem() {
    if (currentIndex < items.length - 1) {
      setState(() {
        currentIndex++;
        recognized = '';
        correct = null;
      });
    } else {
      if (widget.isBottomSheet) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã hoàn thành bài luyện tập!')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    
    if (isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (errorMessage != null) {
      content = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(errorMessage!, style: const TextStyle(color: AppColors.muted)),
          ],
        ),
      );
    } else {
      final item = items[currentIndex];
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: ResponsiveHelper.contentMaxWidth(context)),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              ResponsiveHelper.horizontalPadding(context),
              widget.isBottomSheet ? 12 : 8,
              ResponsiveHelper.horizontalPadding(context),
              30,
            ),
            children: [
          if (widget.isBottomSheet)
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
              if (items.length > 1)
                Text(
                  '${currentIndex + 1} / ${items.length}',
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
                PinyinText(
                  chinese: item.targetText,
                  pinyin: item.pinyin,
                  chineseStyle: TextStyle(
                    fontSize: item.targetText.length > 8 ? 32 : 46,
                    height: 1.2,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'FZKaiTiPinyin',
                    fontFamilyFallback: const ['FZKaiTiPinyin_1', 'PingFang SC', 'Heiti SC', 'Microsoft YaHei', 'Noto Sans SC'],
                  ),
                  pinyinStyle: const TextStyle(
                    fontSize: 16,
                    color: AppColors.orange,
                    fontWeight: FontWeight.w500,
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
                if (item.audioUrl != null && item.audioUrl!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  IconButton(
                    onPressed: () => audioService.playUrl(item.audioUrl!),
                    icon: const Icon(Icons.volume_up_rounded, color: AppColors.red),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFFFE9E5),
                    ),
                  ),
                ]
              ],
            ),
          ),
          const SizedBox(height: 36),
          Center(
            child: ScaleTransition(
              scale: pulse,
              child: InkWell(
                onTap: busy ? null : start,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.red, AppColors.orange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x45B4232C),
                        blurRadius: 28,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Icon(
                    busy ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                    size: 46,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            busy ? 'Đang nghe… hãy nói tự nhiên' : 'Chạm micro để bắt đầu',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 30),
          if (correct != null)
            _resultCard()
          else
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3EF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.tips_and_updates_outlined, color: AppColors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Mẹo: hãy nói rõ ràng với tốc độ thoải mái. Bạn có thể thử lại bất cứ lúc nào.',
                      style: TextStyle(color: AppColors.muted, height: 1.45),
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

    if (widget.isBottomSheet) {
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
  }

  Widget _resultCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: correct! ? const Color(0xFFE7F7F0) : const Color(0xFFFFE9E7),
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
                color: correct! ? AppColors.success : AppColors.error,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${score.round()}',
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
                    correct!
                        ? 'Phát âm rất tốt!'
                        : 'Gần đúng rồi — thử lại nhé',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Đã nhận diện: ${recognized.isEmpty ? 'Không nghe thấy giọng nói' : recognized}',
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
                onPressed: busy ? null : start,
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Luyện lại'),
              ),
            ),
            if (items.length > 1) ...[
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: busy ? null : nextItem,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(currentIndex < items.length - 1 ? 'Tiếp theo' : 'Hoàn thành'),
                ),
              ),
            ]
          ],
        ),
      ],
    ),
  );
}
