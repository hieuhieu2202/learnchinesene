import 'package:flutter/material.dart';

import '../theme/hsk_palette.dart';
import '../../domain/entities/word.dart';

class WordListItem extends StatefulWidget {
  const WordListItem({
    super.key,
    required this.word,
    this.onTap,
    this.level,
    this.progress,
    this.maxWidth,
    this.showTransliteration = true,
    this.showTranslation = true,
  });

  final Word word;
  final VoidCallback? onTap;
  final int? level;
  final double? progress;
  final double? maxWidth;
  final bool showTransliteration;
  final bool showTranslation;

  @override
  State<WordListItem> createState() => _WordListItemState();
}

class _WordListItemState extends State<WordListItem> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  double _previousProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    // Normalize incoming progress: accept either 0..1 or 0..100
    final raw = widget.progress ?? (widget.word.mastered ? 1.0 : 0.0);
    final normalized = raw > 1.0 ? (raw / 100.0) : raw;
    _previousProgress = normalized.clamp(0.0, 1.0);
    // Initialize animation to avoid LateInitializationError
    _progressAnimation = Tween<double>(
      begin: _previousProgress,
      end: _previousProgress,
    ).animate(CurvedAnimation(parent: _progressController, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(WordListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Normalize incoming progress: accept either 0..1 or 0..100
    final rawNew = widget.progress ?? (widget.word.mastered ? 1.0 : 0.0);
    final newProgress = (rawNew > 1.0 ? (rawNew / 100.0) : rawNew).clamp(0.0, 1.0);

    // Nếu progress thay đổi → trigger animation (chỉ khi tăng lên)
    if (newProgress > _previousProgress) {
      _progressAnimation = Tween<double>(
        begin: _previousProgress,
        end: newProgress,
      ).animate(CurvedAnimation(parent: _progressController, curve: Curves.easeInOut));

      _progressController.forward(from: 0);
      _previousProgress = newProgress;
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = HskPalette.accentForLevel(widget.level ?? 1, theme.colorScheme);
    final rawProgress = widget.progress ?? (widget.word.mastered ? 1.0 : 0.0);
    final progressValue = (rawProgress > 1.0 ? (rawProgress / 100.0) : rawProgress).clamp(0.0, 1.0);
    final indicatorValue = progressValue == 0 ? 0.04 : progressValue;
    final isCompact = !widget.showTranslation && !widget.showTransliteration;
    final surfaceTint = Color.lerp(
          theme.colorScheme.surface,
          accent,
          isCompact ? 0.02 : 0.05,
        ) ??
        theme.colorScheme.surface;
    final borderColor = Color.lerp(
          Colors.transparent,
          accent,
          widget.word.mastered ? 0.55 : (isCompact ? 0.25 : 0.35),
        ) ??
        Colors.transparent;
    final indicatorBackground = Color.lerp(
          theme.colorScheme.surfaceVariant,
          theme.colorScheme.surface,
          0.4,
        ) ??
        theme.colorScheme.surfaceVariant;

    final translationColor = Color.lerp(
          theme.colorScheme.onSurface,
          Colors.transparent,
          0.24,
        ) ??
        theme.colorScheme.onSurface;
    final transliterationColor = Color.lerp(
          theme.colorScheme.onSurface,
          Colors.transparent,
          0.45,
        ) ??
        theme.colorScheme.onSurface;

    final borderRadius = BorderRadius.circular(isCompact ? 16 : 20);
    final padding = isCompact
        ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
        : const EdgeInsets.fromLTRB(16, 14, 16, 12);

    Widget buildCompactContent() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  widget.word.word,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 10,
                height: 10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                  child: widget.word.mastered
                      ? const Center(
                          child: Icon(
                            Icons.check,
                            size: 8,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // ⭐ Progress bar với animation
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              final displayValue = _progressAnimation.isAnimating
                  ? _progressAnimation.value
                  : indicatorValue;

              return ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: SizedBox(
                  height: 3,
                  child: LinearProgressIndicator(
                    value: displayValue == 0 ? 0.04 : displayValue,
                    backgroundColor: indicatorBackground,
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                  ),
                ),
              );
            },
          ),
        ],
      );
    }

    Widget buildDetailedContent() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  widget.word.word,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.15,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                widget.word.mastered
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                size: 16,
                color: accent,
              ),
            ],
          ),
          if (widget.showTranslation && widget.word.translation.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              widget.word.translation,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: translationColor,
              ),
            ),
          ],
          if (widget.showTransliteration &&
              widget.word.transliteration.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              widget.word.transliteration,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: transliterationColor,
                letterSpacing: 0.2,
              ),
            ),
          ],
          SizedBox(
            height:
                widget.showTranslation || widget.showTransliteration ? 12 : 8,
          ),
          // ⭐ Progress bar với animation
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              final displayValue = _progressAnimation.isAnimating
                  ? _progressAnimation.value
                  : indicatorValue;

              return ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: SizedBox(
                  height: 4,
                  child: LinearProgressIndicator(
                    value: displayValue == 0 ? 0.04 : displayValue,
                    backgroundColor: indicatorBackground,
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                  ),
                ),
              );
            },
          ),
        ],
      );
    }

    Widget content = isCompact ? buildCompactContent() : buildDetailedContent();

    Widget tile = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: borderRadius,
        child: Ink(
          decoration: BoxDecoration(
            color: surfaceTint,
            borderRadius: borderRadius,
            border: Border.all(color: borderColor, width: 1),
            boxShadow: isCompact
                ? [
                    BoxShadow(
                      color: accent.withAlpha(13),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: accent.withAlpha(20),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
          ),
          padding: padding,
          child: content,
        ),
      ),
    );

    if (widget.maxWidth != null) {
      tile = ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: widget.maxWidth! * 0.6,
          maxWidth: widget.maxWidth!,
        ),
        child: tile,
      );
    }

    return isCompact
        ? SizedBox(width: widget.maxWidth ?? 148, child: tile)
        : SizedBox(width: widget.maxWidth ?? double.infinity, child: tile);
  }
}
