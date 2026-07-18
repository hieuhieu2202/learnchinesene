import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../database/db_helper.dart';
import '../../../models/hanzi_character.dart';
import '../painters/hanzi_grid_painter.dart';
import '../painters/hanzi_writing_painter.dart';
import '../painters/user_stroke_painter.dart';
import '../services/stroke_validator.dart';
import '../services/svg_stroke_parser.dart';
import '../models/hanzi_practice_config.dart';
import '../../../core/responsive/responsive_layout.dart';

class HanziWritingScreen extends StatefulWidget {
  final int characterId;

  const HanziWritingScreen({
    super.key,
    required this.characterId,
  });

  @override
  State<HanziWritingScreen> createState() => _HanziWritingScreenState();
}

class _HanziWritingScreenState extends State<HanziWritingScreen>
    with SingleTickerProviderStateMixin {
  HanziCharacter? _character;
  List<Path> _strokePaths = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Round configs & stats
  List<HanziPracticeRoundConfig> _roundConfigs = [];
  int _currentRoundIndex = 0; // 0 to 9
  int _currentStrokeIndex = 0; // active stroke index in character
  final List<int> _completedStrokeIndexes = [];
  final List<double> _currentRoundStrokeScores = [];
  final List<HanziRoundResult> _completedRoundResults = [];

  int _totalAttempts = 0; // touch attempts in this round
  int _failedAttemptsThisStroke = 0;
  DateTime? _sessionStartedAt;
  DateTime? _roundStartedAt;

  // Active user writing line repaint notifier
  final ValueNotifier<UserStroke> _userStrokeNotifier = ValueNotifier(
    const UserStroke(points: [], color: Colors.blue),
  );

  String _validationFeedback = 'Hãy viết nét đầu tiên.';
  Color _feedbackColor = Colors.grey;

  // Snap animation variables
  late AnimationController _snapAnimationController;
  int? _animatingStrokeIndex;

  bool _isRoundCompleted = false;
  bool _isSessionCompleted = false;
  Timer? _autoNextRoundTimer;

  @override
  void initState() {
    super.initState();
    _snapAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
        setState(() {});
      });
    _loadCharacter();
  }

  @override
  void dispose() {
    _autoNextRoundTimer?.cancel();
    _snapAnimationController.dispose();
    _userStrokeNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadCharacter() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final char = await DbHelper.instance
          .getCharacterForWritingById(widget.characterId);
      if (char == null) {
        setState(() {
          _errorMessage = 'Không tìm thấy dữ liệu chữ Hán này.';
          _isLoading = false;
        });
        return;
      }

      if (char.strokePathData.trim().isEmpty) {
        setState(() {
          _character = char;
          _errorMessage = 'Chữ này chưa có dữ liệu nét vẽ.';
          _isLoading = false;
        });
        return;
      }

      final paths = SvgStrokeParser.parseStrokesToPaths(char.strokePathData);
      if (paths.isEmpty) {
        setState(() {
          _character = char;
          _errorMessage = 'Dữ liệu nét vẽ không hợp lệ.';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _character = char;
        _strokePaths = paths;
        _isLoading = false;

        // Initialize session stats
        _roundConfigs = generateRoundConfigs(paths.length);
        _currentRoundIndex = 0;
        _completedRoundResults.clear();
        _sessionStartedAt = DateTime.now();
        _isRoundCompleted = false;
        _isSessionCompleted = false;

        _initializeRound(_roundConfigs[_currentRoundIndex]);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi kết nối database: $e';
        _isLoading = false;
      });
    }
  }

  void _initializeRound(HanziPracticeRoundConfig config) {
    _currentStrokeIndex = config.prefilledStrokeCount;

    _completedStrokeIndexes
      ..clear()
      ..addAll(
        List.generate(
          config.prefilledStrokeCount,
          (index) => index,
        ),
      );

    _currentRoundStrokeScores.clear();
    _userStrokeNotifier.value =
        const UserStroke(points: [], color: Colors.blue);
    _totalAttempts = 0;
    _failedAttemptsThisStroke = 0;
    _animatingStrokeIndex = null;
    _roundStartedAt = DateTime.now();
    _isRoundCompleted = false;

    // Reset feedback states
    if (_currentStrokeIndex >= _strokePaths.length) {
      _validationFeedback = 'Hoàn thành lượt vẽ.';
      _feedbackColor = AppColors.success;
    } else {
      final nextNum = _currentStrokeIndex + 1;
      final totalNum = _strokePaths.length;
      _validationFeedback = 'Hãy viết nét $nextNum/$totalNum.';
      _feedbackColor = Colors.grey;
    }
  }

  void _handlePanStart(DragStartDetails details, BoxConstraints constraints) {
    if (_isRoundCompleted || _isSessionCompleted) return;
    _userStrokeNotifier.value = UserStroke(
      points: [details.localPosition],
      color: Colors.blue,
    );
  }

  void _handlePanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (_isRoundCompleted || _isSessionCompleted) return;
    final currentStroke = _userStrokeNotifier.value;
    _userStrokeNotifier.value = UserStroke(
      points: List.from(currentStroke.points)..add(details.localPosition),
      color: currentStroke.color,
    );
  }

  void _handlePanEnd(DragEndDetails details, BoxConstraints constraints) {
    if (_isRoundCompleted || _isSessionCompleted) return;
    final userPoints = _userStrokeNotifier.value.points;
    if (userPoints.isEmpty) return;

    _totalAttempts++;

    final char = _character!;
    final Size canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

    // Convert user points to SVG space
    final scaleX = canvasSize.width / char.viewBoxWidth;
    final scaleY = canvasSize.height / char.viewBoxHeight;
    final scale = math.min(scaleX, scaleY);
    final offsetX = (canvasSize.width - char.viewBoxWidth * scale) / 2;
    final offsetY = (canvasSize.height - char.viewBoxHeight * scale) / 2;

    final List<Offset> svgSpacePoints = userPoints.map((p) {
      return Offset(
        (p.dx - offsetX) / scale,
        (p.dy - offsetY) / scale,
      );
    }).toList();

    // Validate against current stroke
    final currentPath = _strokePaths[_currentStrokeIndex];
    final result = StrokeValidator.validate(
      userPoints: svgSpacePoints,
      refPath: currentPath,
    );

    if (result.isValid) {
      _acceptCurrentStroke(result.score);
    } else {
      // Draw failed stroke in red
      _userStrokeNotifier.value = UserStroke(
        points: userPoints,
        color: AppColors.error,
      );
      _failedAttemptsThisStroke++;

      setState(() {
        _validationFeedback = result.errorMessage ?? 'Nét vẽ chưa đúng.';
        _feedbackColor = AppColors.error;
      });

      // Clear the user's drawing after 700ms so they can try again
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted && _failedAttemptsThisStroke > 0) {
          if (_userStrokeNotifier.value.color == AppColors.error) {
            _userStrokeNotifier.value =
                const UserStroke(points: [], color: Colors.blue);
          }
        }
      });
    }
  }

  void _acceptCurrentStroke(double score) {
    setState(() {
      _completedStrokeIndexes.add(_currentStrokeIndex);
      _currentRoundStrokeScores.add(score);

      _userStrokeNotifier.value =
          const UserStroke(points: [], color: Colors.blue);
      _failedAttemptsThisStroke = 0;

      // Start snap animation on this stroke
      _animatingStrokeIndex = _currentStrokeIndex;
      _snapAnimationController.forward(from: 0.0);

      _currentStrokeIndex++;

      if (_currentStrokeIndex >= _strokePaths.length) {
        _completeCurrentRound();
      } else {
        final nextNum = _currentStrokeIndex + 1;
        final totalNum = _strokePaths.length;
        _validationFeedback = 'Đúng rồi! Tiếp tục nét $nextNum/$totalNum.';
        _feedbackColor = AppColors.success;
      }
    });
  }

  void _completeCurrentRound() {
    final roundConfig = _roundConfigs[_currentRoundIndex];
    final duration = DateTime.now().difference(_roundStartedAt!).inMilliseconds;
    final roundScore = _currentRoundStrokeScores.isEmpty
        ? 0.0
        : _currentRoundStrokeScores.reduce((a, b) => a + b) /
            _currentRoundStrokeScores.length;

    final drawnStrokes = _strokePaths.length - roundConfig.prefilledStrokeCount;

    final roundResult = HanziRoundResult(
      roundNumber: roundConfig.roundNumber,
      mode: roundConfig.mode,
      drawnStrokeCount: drawnStrokes,
      attemptCount: _totalAttempts,
      score: roundScore,
      durationMilliseconds: duration,
    );

    _completedRoundResults.add(roundResult);

    if (_currentRoundIndex == 9) {
      // 10th round finished
      setState(() {
        _isSessionCompleted = true;
        _isRoundCompleted = false;
        _validationFeedback = 'Luyện tập hoàn thành!';
        _feedbackColor = AppColors.success;
      });
      _saveProgress();
    } else {
      setState(() {
        _isRoundCompleted = true;
        _validationFeedback = 'Hoàn thành lượt vẽ!';
        _feedbackColor = AppColors.success;
      });
    }
  }

  Future<void> _saveProgress() async {
    try {
      final db = DbHelper.instance;
      final totalScore =
          _completedRoundResults.map((r) => r.score).fold(0.0, (a, b) => a + b);
      final avgScore = _completedRoundResults.isEmpty
          ? 0.0
          : totalScore / _completedRoundResults.length;
      final totalAttemptsSum = _completedRoundResults
          .map((r) => r.attemptCount)
          .fold(0, (a, b) => a + b);

      await db.saveHanziWritingProgress(
        characterId: widget.characterId,
        score: avgScore,
        attempts: totalAttemptsSum,
      );
    } catch (_) {}
  }

  void _goToNextRound() {
    _autoNextRoundTimer?.cancel();
    setState(() {
      _currentRoundIndex++;
      _initializeRound(_roundConfigs[_currentRoundIndex]);
    });
  }

  Future<void> _goToNextCharacter() async {
    final db = DbHelper.instance;
    final allChars = await db.getCharactersForWriting();
    if (allChars.isNotEmpty) {
      final currentIndex =
          allChars.indexWhere((c) => c.id == widget.characterId);
      if (currentIndex != -1 && currentIndex < allChars.length - 1) {
        final nextChar = allChars[currentIndex + 1];
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HanziWritingScreen(characterId: nextChar.id),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã hết chữ trong danh sách!')),
          );
        }
      }
    }
  }

  void _resetWholeSession() {
    _autoNextRoundTimer?.cancel();
    setState(() {
      _currentRoundIndex = 0;
      _completedRoundResults.clear();
      _isRoundCompleted = false;
      _isSessionCompleted = false;
      _sessionStartedAt = DateTime.now();
      _initializeRound(_roundConfigs[_currentRoundIndex]);
    });
  }

  String _getModeName(HanziPracticeMode mode) {
    switch (mode) {
      case HanziPracticeMode.guidedTrace:
        return 'Luyện viết có hướng dẫn';
      case HanziPracticeMode.completeRemaining:
        return 'Hoàn thiện nét vẽ';
      case HanziPracticeMode.faintCharacter:
        return 'Luyện viết theo nét mờ';
      case HanziPracticeMode.startPointOnly:
        return 'Chỉ hiện điểm bắt đầu';
      case HanziPracticeMode.fromScratch:
        return 'Tự viết theo trí nhớ';
    }
  }

  String _buildRoundInstruction({
    required HanziPracticeMode mode,
    required int prefilledStrokeCount,
  }) {
    switch (mode) {
      case HanziPracticeMode.guidedTrace:
        return 'Viết theo nét được hướng dẫn';
      case HanziPracticeMode.completeRemaining:
        if (prefilledStrokeCount > 0) {
          return '$prefilledStrokeCount nét đã có sẵn · Hoàn thành các nét còn lại';
        }
        return 'Hoàn thành các nét còn lại';
      case HanziPracticeMode.faintCharacter:
        return 'Viết lại toàn bộ chữ';
      case HanziPracticeMode.startPointOnly:
        return 'Chỉ có điểm bắt đầu làm gợi ý';
      case HanziPracticeMode.fromScratch:
        return 'Viết toàn bộ chữ theo trí nhớ';
    }
  }

  String get _statusMessage {
    if (_isRoundCompleted || _isSessionCompleted) {
      return '';
    }

    if (_feedbackColor == AppColors.error) {
      return 'Nét chưa đúng, hãy thử lại';
    }

    final nextNum = _currentStrokeIndex + 1;
    final totalNum = _strokePaths.length;

    if (_currentStrokeIndex == 0 && _failedAttemptsThisStroke == 0) {
      return 'Hãy viết nét 1/$totalNum';
    }

    if (_feedbackColor == AppColors.success) {
      return 'Đúng rồi! Tiếp tục nét $nextNum/$totalNum';
    }

    return 'Hãy viết nét $nextNum/$totalNum';
  }

  Widget _buildProgressDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(10, (index) {
        final isCompleted = index < _currentRoundIndex;
        final isCurrent = index == _currentRoundIndex;

        Color color;
        double size = 10.0;
        BoxBorder? border;
        List<BoxShadow>? shadow;

        if (isCompleted) {
          color = AppColors.orange;
        } else if (isCurrent) {
          color = AppColors.orange;
          size = 16.0;
          border = Border.all(color: Colors.white, width: 2.0);
          shadow = const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ];
        } else {
          color = Colors.grey[200]!;
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: border,
            boxShadow: shadow,
          ),
        );
      }),
    );
  }

  Widget _buildRoundCompleteOverlay(
      BoxConstraints constraints, HanziPracticeRoundConfig currentConfig) {
    final roundNumber = currentConfig.roundNumber;
    final roundScore = _currentRoundStrokeScores.isEmpty
        ? 0.0
        : _currentRoundStrokeScores.reduce((a, b) => a + b) /
            _currentRoundStrokeScores.length;

    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        onPanStart: (_) {},
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.88),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.green,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hoàn thành lượt $roundNumber/10',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Điểm: ${roundScore.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.orange,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: FilledButton(
                        onPressed: _goToNextRound,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                _currentRoundIndex == 9
                                    ? 'Xem kết quả'
                                    : 'Tiếp tục lượt ${_currentRoundIndex + 2}/10',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionSummary() {
    final totalScore =
        _completedRoundResults.map((r) => r.score).fold(0.0, (a, b) => a + b);
    final avgScore = _completedRoundResults.isEmpty
        ? 0.0
        : totalScore / _completedRoundResults.length;

    final lastThree = _completedRoundResults
        .sublist(math.max(0, _completedRoundResults.length - 3));
    final avgLastThree = lastThree.isEmpty
        ? 0.0
        : lastThree.map((r) => r.score).fold(0.0, (a, b) => a + b) /
            lastThree.length;

    final totalDrawn = _completedRoundResults
        .map((r) => r.drawnStrokeCount)
        .fold(0, (a, b) => a + b);
    final totalAttemptsSum = _completedRoundResults
        .map((r) => r.attemptCount)
        .fold(0, (a, b) => a + b);
    final strokeAccuracy =
        totalAttemptsSum > 0 ? (totalDrawn / totalAttemptsSum) * 100 : 0.0;
    final totalWrong = totalAttemptsSum - totalDrawn;

    final totalDurationMs = _completedRoundResults
        .map((r) => r.durationMilliseconds)
        .fold(0, (a, b) => a + b);
    final totalDurationSec = totalDurationMs ~/ 1000;
    final durationText = totalDurationSec >= 60
        ? '${totalDurationSec ~/ 60} phút ${totalDurationSec % 60} giây'
        : '$totalDurationSec giây';

    final maxScore = _completedRoundResults.isEmpty
        ? 0.0
        : _completedRoundResults.map((r) => r.score).reduce(math.max);

    final lastRoundScore = _completedRoundResults.isEmpty
        ? 0.0
        : _completedRoundResults.last.score;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Stack(
        children: [
          // Background Gradient Decoration
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 350,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.orange.withOpacity(0.15),
                    const Color(0xFFF9F9F9),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth:
                                ResponsiveHelper.contentMaxWidth(context)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24.0, vertical: 16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Header Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TweenAnimationBuilder<double>(
                                    duration: const Duration(milliseconds: 600),
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    curve: Curves.elasticOut,
                                    builder: (context, scale, child) {
                                      return Transform.scale(
                                        scale: scale,
                                        child: Container(
                                          width: 52,
                                          height: 52,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                AppColors.orange,
                                                AppColors.orange
                                                    .withOpacity(0.7)
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.orange
                                                    .withOpacity(0.3),
                                                blurRadius: 12,
                                                offset: const Offset(0, 6),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                              Icons.emoji_events_rounded,
                                              color: Colors.white,
                                              size: 28),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Tuyệt vời!',
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black87),
                                      ),
                                      Text(
                                        'Hoàn thành chữ "${_character?.character ?? ""}"',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Main Score & Accuracy Card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 24, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8)),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // Left: Score
                                    Column(
                                      children: [
                                        const Text('ĐIỂM TRUNG BÌNH',
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.black45)),
                                        TweenAnimationBuilder<double>(
                                          duration: const Duration(
                                              milliseconds: 1200),
                                          tween:
                                              Tween(begin: 0.0, end: avgScore),
                                          curve: Curves.easeOutCubic,
                                          builder: (context, value, child) {
                                            return Text(
                                              value.toStringAsFixed(0),
                                              style: const TextStyle(
                                                  fontSize: 48,
                                                  fontWeight: FontWeight.w900,
                                                  color: AppColors.orange,
                                                  height: 1.2),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    Container(
                                        width: 1,
                                        height: 60,
                                        color: Colors.grey[200]),
                                    // Right: Accuracy
                                    Column(
                                      children: [
                                        const Text('CHÍNH XÁC',
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.black45)),
                                        Text(
                                          '${strokeAccuracy.toStringAsFixed(0)}%',
                                          style: const TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.green,
                                              height: 1.5),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Stats Grid (2x2 highly compact)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4)),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                            child: _buildCompactStat(
                                                Icons.trending_up_rounded,
                                                '3 lượt cuối',
                                                avgLastThree.toStringAsFixed(0),
                                                Colors.blue)),
                                        Container(
                                            width: 1,
                                            height: 40,
                                            color: Colors.grey[100]),
                                        Expanded(
                                            child: _buildCompactStat(
                                                Icons.star_rounded,
                                                'Cao nhất',
                                                maxScore.toStringAsFixed(0),
                                                Colors.orange)),
                                      ],
                                    ),
                                    const Divider(
                                        height: 32,
                                        thickness: 1,
                                        color: Color(0xFFF5F5F5)),
                                    Row(
                                      children: [
                                        Expanded(
                                            child: _buildCompactStat(
                                                Icons.timer_rounded,
                                                'Thời gian',
                                                durationText,
                                                Colors.purple)),
                                        Container(
                                            width: 1,
                                            height: 40,
                                            color: Colors.grey[100]),
                                        Expanded(
                                            child: _buildCompactStat(
                                                Icons.error_outline_rounded,
                                                'Viết sai',
                                                '$totalWrong lần',
                                                Colors.red)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Action Buttons
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _goToNextCharacter,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.orange,
                                    foregroundColor: Colors.white,
                                    elevation: 4,
                                    shadowColor:
                                        AppColors.orange.withOpacity(0.4),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                  ),
                                  child: const Text('Học chữ tiếp theo',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 48,
                                      child: OutlinedButton(
                                        onPressed: _resetWholeSession,
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                              color: Colors.grey[300]!,
                                              width: 1.5),
                                          foregroundColor: Colors.black87,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16)),
                                        ),
                                        child: const Text('Luyện lại',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: SizedBox(
                                      height: 48,
                                      child: OutlinedButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                              color: Colors.grey[300]!,
                                              width: 1.5),
                                          foregroundColor: Colors.black87,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16)),
                                        ),
                                        child: const Text('Danh sách',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStat(
      IconData icon, String title, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black45)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87)),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isSessionCompleted) {
      return _buildSessionSummary();
    }

    final currentConfig =
        (_isLoading || _errorMessage != null || _roundConfigs.isEmpty)
            ? null
            : _roundConfigs[_currentRoundIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(_character != null
            ? 'Viết chữ: ${_character!.character}'
            : 'Viết chữ Hán'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            size: 64, color: AppColors.error),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadCharacter,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                )
              : SafeArea(
                  child: Column(
                    children: [
                      // Header: two columns layout
                      Container(
                        color: Colors.white,
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth:
                                    ResponsiveHelper.contentMaxWidth(context)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Left Column (Pinyin, Vietnamese meaning)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _character!.pinyin ?? '',
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.orange,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _character!.meaning ?? '',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: AppColors.muted,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Right Column (Round/Stroke stats)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Lượt ${_currentRoundIndex + 1}/10',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.orange,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Nét ${math.min(_currentStrokeIndex + 1, _strokePaths.length)}/${_strokePaths.length}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Progress dots
                      _buildProgressDots(),
                      const SizedBox(height: 10),

                      // Mode description
                      Text(
                        _buildRoundInstruction(
                          mode: currentConfig!.mode,
                          prefilledStrokeCount:
                              currentConfig.prefilledStrokeCount,
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Status feedback above the board (using AnimatedSwitcher)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        height: 30,
                        alignment: Alignment.center,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return FadeTransition(
                                opacity: animation, child: child);
                          },
                          child: _statusMessage.isEmpty
                              ? const SizedBox.shrink()
                              : Text(
                                  _statusMessage,
                                  key: ValueKey<String>(_statusMessage),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: _feedbackColor == AppColors.error
                                        ? AppColors.error
                                        : _feedbackColor == AppColors.success
                                            ? Colors.green[700]
                                            : Colors.black87,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Writing Canvas Area
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 390,
                                maxHeight: 390,
                              ),
                              child: AspectRatio(
                                aspectRatio: 1.0,
                                child: Container(
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      return GestureDetector(
                                        onPanStart: (details) =>
                                            _handlePanStart(
                                                details, constraints),
                                        onPanUpdate: (details) =>
                                            _handlePanUpdate(
                                                details, constraints),
                                        onPanEnd: (details) =>
                                            _handlePanEnd(details, constraints),
                                        child: Stack(
                                          children: [
                                            // 1. Static grid guideline
                                            RepaintBoundary(
                                              child: CustomPaint(
                                                size: Size(constraints.maxWidth,
                                                    constraints.maxHeight),
                                                painter: HanziGridPainter(),
                                              ),
                                            ),
                                            // 2. Character SVG template and snap animations
                                            RepaintBoundary(
                                              child: CustomPaint(
                                                size: Size(constraints.maxWidth,
                                                    constraints.maxHeight),
                                                painter: HanziWritingPainter(
                                                  strokePaths: _strokePaths,
                                                  completedIndexes: Set.from(
                                                      _completedStrokeIndexes),
                                                  currentIndex:
                                                      _currentStrokeIndex,
                                                  viewBoxWidth:
                                                      _character!.viewBoxWidth,
                                                  viewBoxHeight:
                                                      _character!.viewBoxHeight,
                                                  guideOpacity: currentConfig
                                                      .guideOpacity,
                                                  showCurrentStroke:
                                                      currentConfig
                                                          .showCurrentStroke,
                                                  showStartPoint: currentConfig
                                                      .showStartPoint,
                                                  showDirectionArrow:
                                                      currentConfig
                                                          .showDirectionArrow,
                                                  animatingStrokeIndex:
                                                      _animatingStrokeIndex,
                                                  snapAnimationValue:
                                                      _snapAnimationController
                                                          .value,
                                                ),
                                              ),
                                            ),
                                            // 3. User active hand drawing points (optimised repaint using ValueListenableBuilder)
                                            RepaintBoundary(
                                              child: ValueListenableBuilder<
                                                  UserStroke>(
                                                valueListenable:
                                                    _userStrokeNotifier,
                                                builder:
                                                    (context, stroke, child) {
                                                  return CustomPaint(
                                                    size: Size(
                                                        constraints.maxWidth,
                                                        constraints.maxHeight),
                                                    painter: UserStrokePainter(
                                                      points: stroke.points,
                                                      strokeColor: stroke.color,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            // 4. Round Complete Overlay Card
                                            if (_isRoundCompleted)
                                              _buildRoundCompleteOverlay(
                                                  constraints, currentConfig),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }
}

class UserStroke {
  final List<Offset> points;
  final Color color;

  const UserStroke({
    required this.points,
    required this.color,
  });
}
