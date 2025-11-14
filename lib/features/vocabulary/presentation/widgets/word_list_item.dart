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
        borderRadius: BorderRadius.circular(30),
        child: Ink(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: accent.withOpacity(0.18),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _GlyphBadge(
                accent: accent,
                glyph: word.word,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            word.transliteration,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _LevelDot(color: accent),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      word.translation,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.35,
                        color: theme.colorScheme.onSurface.withOpacity(0.78),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
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
      width: 70,
      height: 82,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withOpacity(0.28),
            accent.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      alignment: Alignment.center,
      child: Text(
        glyph,
        style: theme.textTheme.displaySmall?.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: 36,
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
      width: 12,
      height: 12,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accent.withOpacity(0.32),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            mastered ? Icons.check_rounded : Icons.brightness_1_outlined,
            size: 18,
            color: accent,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
