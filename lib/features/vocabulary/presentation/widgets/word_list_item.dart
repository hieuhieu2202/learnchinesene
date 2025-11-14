import 'package:flutter/material.dart';

import '../theme/hsk_palette.dart';
import '../../domain/entities/word.dart';

class WordListItem extends StatelessWidget {
  const WordListItem({
    super.key,
    required this.word,
    this.onTap,
    this.level,
  });

  final Word word;
  final VoidCallback? onTap;
  final int? level;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = HskPalette.accentForLevel(level ?? 1, theme.colorScheme);
    final statusLabel = word.mastered ? 'Đã thuộc' : 'Chưa hoàn thành';
    final statusColor = word.mastered ? accent : theme.colorScheme.outline;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: accent.withOpacity(0.14),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.onSurface.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _GlyphBadge(
                accent: accent,
                glyph: word.word,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            word.translation,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _LevelDot(color: accent),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      word.transliteration,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withOpacity(0.65),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _StatusBadge(
                label: statusLabel,
                accent: statusColor,
                mastered: word.mastered,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlyphBadge extends StatelessWidget {
  const _GlyphBadge({
    required this.accent,
    required this.glyph,
  });

  final Color accent;
  final String glyph;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withOpacity(0.32),
            accent.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      child: Text(
        glyph,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 26,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _LevelDot extends StatelessWidget {
  const _LevelDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.accent,
    required this.mastered,
  });

  final String label;
  final Color accent;
  final bool mastered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = mastered
        ? accent.withOpacity(0.16)
        : theme.colorScheme.surfaceVariant.withOpacity(0.55);
    final borderColor = mastered ? accent.withOpacity(0.4) : Colors.transparent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: mastered ? 1 : 0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            mastered ? Icons.check_rounded : Icons.radio_button_unchecked,
            size: 16,
            color: mastered
                ? accent
                : theme.colorScheme.onSurface.withOpacity(0.45),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: mastered
                  ? accent
                  : theme.colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
