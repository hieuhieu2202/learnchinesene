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
    final progressValue = (progress ?? (word.mastered ? 1.0 : 0.0)).clamp(0.0, 1.0);
    final indicatorValue = progressValue == 0 ? 0.04 : progressValue;
    final borderColor = Color.lerp(Colors.transparent, accent, word.mastered ? 0.5 : 0.2)!;
    final shadowColor = Color.lerp(accent, Colors.transparent, 0.7)!;
    final surfaceTint = Color.lerp(theme.colorScheme.surface, accent, 0.05)!;
    final translationColor =
        Color.lerp(theme.colorScheme.onSurface, Colors.transparent, 0.22)!;
    final transliterationColor =
        Color.lerp(theme.colorScheme.onSurface, Colors.transparent, 0.45)!;
    final iconColor = word.mastered
        ? accent
        : Color.lerp(theme.colorScheme.onSurface, Colors.transparent, 0.6)!;
    final indicatorBackground =
        Color.lerp(theme.colorScheme.surfaceVariant, theme.colorScheme.surface, 0.3)!;

    Widget tile = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: surfaceTint,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(
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
                        fontSize: showTranslation || showTransliteration ? 20 : 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.15,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    word.mastered
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked,
                    size: 16,
                    color: iconColor,
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
              if (showTransliteration && word.transliteration.trim().isNotEmpty) ...[
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
              SizedBox(height: (showTranslation && word.translation.trim().isNotEmpty) ||
                      (showTransliteration && word.transliteration.trim().isNotEmpty)
                  ? 12
                  : 8),
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
          ),
        ),
      ),
    );

    if (maxWidth != null) {
      tile = ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: maxWidth! * 0.7,
          maxWidth: maxWidth!,
        ),
        child: tile,
      );
    } else {
      tile = SizedBox(width: double.infinity, child: tile);
    }

    return tile;
  }
}
