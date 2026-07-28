import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../database/db_helper.dart';
import '../../models/word.dart';
import '../../core/responsive/responsive_layout.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  int _selectedHskLevel = 1; // 1 to 6. 0 for "Review Due"
  List<Word> _deck = [];
  int _currentIndex = 0;
  bool _isFlipped = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    _loadDeck();
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  Future<void> _loadDeck() async {
    setState(() {
      _isLoading = true;
      _currentIndex = 0;
      _isFlipped = false;
      _deck = [];
    });
    _flipController.reset();

    try {
      final db = DbHelper.instance;
      List<Word> words = [];
      if (_selectedHskLevel == 0) {
        words = await db.getReviewWords();
      } else {
        // Fetch vocabulary words for selected level
        final units = await db.getUnitsByLevel(_selectedHskLevel);
        for (var unit in units) {
          final unitWords = await db.getWordsByUnit(unit.id);
          words.addAll(unitWords);
        }
      }

      // Shuffle deck
      words.shuffle();

      setState(() {
        _deck = words.take(30).toList(); // Limit deck to 30 words per session
      });
    } catch (_) {}

    setState(() {
      _isLoading = false;
    });
  }

  void _flipCard() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  Future<void> _answerCard(String rating) async {
    if (_currentIndex >= _deck.length) return;
    final word = _deck[_currentIndex];

    // Spaced repetition logic mapping
    bool isCorrect = true;
    if (rating == 'hard') {
      isCorrect = false;
    }

    try {
      await DbHelper.instance.upsertProgress(
        wordId: word.id,
        isCorrect: isCorrect,
      );
    } catch (_) {}

    // Flip back & go to next card
    if (_isFlipped) {
      _flipCard();
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }

    setState(() {
      _currentIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxWidth = ResponsiveHelper.contentMaxWidth(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flashcards ôn tập',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            children: [
              // HSK level filter chips
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildChip(0, 'Cần ôn gấp'),
                    ...List.generate(
                        6, (i) => _buildChip(i + 1, 'HSK ${i + 1}')),
                  ],
                ),
              ),
              const Divider(height: 24),

              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _deck.isEmpty
                        ? _buildEmptyState()
                        : _currentIndex >= _deck.length
                            ? _buildCompletedState()
                            : _buildCardContainer(theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(int val, String label) {
    final isSelected = _selectedHskLevel == val;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedHskLevel = val;
            });
            _loadDeck();
          }
        },
        selectedColor: AppColors.red.withOpacity(0.2),
        checkmarkColor: AppColors.red,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.red : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.style_outlined,
              size: 72,
              color: AppColors.muted,
            ),
            const SizedBox(height: 16),
            const Text(
              'Không tìm thấy thẻ nào.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedHskLevel == 0
                  ? 'Tuyệt vời! Bạn không còn thẻ nào cần ôn hôm nay.'
                  : 'Không tìm thấy dữ liệu từ vựng cho cấp độ này.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 6,
          shadowColor: Colors.black.withOpacity(0.06),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.celebration_rounded,
                    size: 72, color: AppColors.orange),
                const SizedBox(height: 16),
                const Text(
                  '🎉 Hoàn thành session! 🎉',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bạn đã ôn hết các thẻ từ vựng trong session này.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _loadDeck,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Ôn tiếp tục'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContainer(ThemeData theme) {
    final word = _deck[_currentIndex];
    final progress = _currentIndex / _deck.length;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thẻ: ${_currentIndex + 1} / ${_deck.length}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.muted),
              ),
              Text(
                'Độ chính xác: ${(progress * 100).round()}%',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: theme.colorScheme.surfaceVariant,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.red),
            ),
          ),
          const Spacer(),

          // 3D Flip Card
          SizedBox(
            width: double.infinity,
            height: 320,
            child: GestureDetector(
              onTap: _flipCard,
              child: AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  final angle = _flipAnimation.value * math.pi;
                  final isBack = angle >= math.pi / 2;
                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // perspective
                      ..rotateY(angle),
                    alignment: Alignment.center,
                    child: isBack
                        ? Transform(
                            transform: Matrix4.identity()..rotateY(math.pi),
                            alignment: Alignment.center,
                            child: _buildCardBack(word),
                          )
                        : _buildCardFront(word),
                  );
                },
              ),
            ),
          ),

          const Spacer(),

          // SRS Buttons visible when flipped
          AnimatedOpacity(
            opacity: _isFlipped ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: IgnorePointer(
              ignoring: !_isFlipped,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSrsButton('hard', 'Khó', AppColors.error),
                  _buildSrsButton('good', 'Vừa', AppColors.orange),
                  _buildSrsButton('easy', 'Dễ', AppColors.success),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSrsButton(String val, String label, Color color) {
    return ElevatedButton(
      onPressed: () => _answerCard(val),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildCardFront(Word word) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.08),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFF0E7E5)),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              word.chinese,
              style: const TextStyle(
                fontFamily: 'FZKaiTiPinyin',
                fontSize: 78,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app_rounded, color: AppColors.muted, size: 20),
                SizedBox(width: 6),
                Text(
                  'Chạm để lật thẻ',
                  style: TextStyle(
                      color: AppColors.muted, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack(Word word) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.08),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFF0E7E5)),
        ),
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              word.chinese,
              style: const TextStyle(
                fontFamily: 'FZKaiTiPinyin',
                fontSize: 32,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              word.vietnamese,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.red,
              ),
            ),
            if (word.english.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'English: ${word.english}',
                style: const TextStyle(fontSize: 14, color: AppColors.muted),
              ),
            ],
            const Divider(height: 32),
            const Text(
              'Từ loại & chi tiết:',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.muted),
            ),
            const SizedBox(height: 6),
            Text(
              word.sectionTitle,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
