import 'package:flutter/material.dart';

import '../theme/hsk_palette.dart';
import '../../domain/entities/word.dart';

class WordListItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = HskPalette.accentForLevel(level ?? 1, theme.colorScheme);
    final progressValue =
        (progress ?? (word.mastered ? 1.0 : 0.0)).clamp(0.0, 1.0);
    final indicatorValue = progressValue == 0 ? 0.04 : progressValue;
    final isCompact = !showTranslation && !showTransliteration;
    final surfaceTint = Color.lerp(
          theme.colorScheme.surface,
          accent,
          isCompact ? 0.02 : 0.05,
        ) ??
        theme.colorScheme.surface;
    final borderColor = Color.lerp(
          Colors.transparent,
          accent,
          word.mastered ? 0.55 : (isCompact ? 0.25 : 0.35),
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
                  word.word,
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
                  child: word.mastered
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
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 3,
              child: LinearProgressIndicator(
                value: indicatorValue,
                backgroundColor: indicatorBackground,
                valueColor: AlwaysStoppedAnimation<Color>(accent),
              ),
            ),
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
                  word.word,
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
                word.mastered
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                size: 16,
                color: accent,
              ),
            ],
          ),
          if (showTranslation && word.translation.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              word.translation,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: translationColor,
              ),
            ),
          ],
          if (showTransliteration &&
              word.transliteration.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              word.transliteration,
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
                showTranslation || showTransliteration ? 12 : 8,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 4,
              child: LinearProgressIndicator(
                value: indicatorValue,
                backgroundColor: indicatorBackground,
                valueColor: AlwaysStoppedAnimation<Color>(accent),
              ),
            ),
          ),
        ],
      );
    }

    Widget content = isCompact ? buildCompactContent() : buildDetailedContent();

    Widget tile = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Ink(
          decoration: BoxDecoration(
            color: surfaceTint,
            borderRadius: borderRadius,
            border: Border.all(color: borderColor, width: 1),
            boxShadow: isCompact
                ? [
                    BoxShadow(
                      color: accent.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: accent.withOpacity(0.08),
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

    if (maxWidth != null) {
      tile = ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: maxWidth! * 0.6,
          maxWidth: maxWidth!,
        ),
        child: tile,
      );
    }

    return isCompact
        ? SizedBox(width: maxWidth ?? 148, child: tile)
        : SizedBox(width: maxWidth ?? double.infinity, child: tile);
  }
}
