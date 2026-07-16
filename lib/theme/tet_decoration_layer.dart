import 'package:flutter/material.dart';

/// UI-only decoration layer for Vietnamese Tết / Year of the Horse.
///
/// NOTE: Deprecated in favor of a small badge next to the greeting on Home.
/// This full-screen overlay approach was removed because it could cover/shift UI.
@Deprecated('Use the small greeting badge in Home instead of a full-screen overlay.')
class TetDecorationLayerVer1Ne extends StatelessWidget {
  const TetDecorationLayerVer1Ne({
    super.key,
    required this.child,
    this.enabled = true,
    this.title = 'Đón năm mới',
    this.subtitle = 'Năm con Ngựa',
    this.reserveTopSpace = true,
    this.topSpaceHeight = 76,
    this.reserveBottomSpace = true,
    this.bottomSpaceHeight = 56,
  });

  final Widget child;
  final bool enabled;
  final String title;
  final String subtitle;

  /// If true, pushes app content down so the banner never covers UI.
  final bool reserveTopSpace;

  /// Extra height (besides SafeArea top padding) reserved for the banner.
  final double topSpaceHeight;

  /// If true, adds bottom padding so content doesn't sit under the stamp.
  final bool reserveBottomSpace;

  /// Extra height (besides SafeArea bottom padding) reserved for the stamp.
  final double bottomSpaceHeight;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    // Subtle, festive overlay. Keep content readable.
    const gold = Color(0xFFFFD700);

    final reservedTop = reserveTopSpace ? (topInset + topSpaceHeight) : 0.0;
    final reservedBottom = reserveBottomSpace ? (bottomInset + bottomSpaceHeight) : 0.0;

    return Stack(
      children: [
        // Soft background wash
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.primary.withValues(alpha: 0.10),
                    cs.tertiary.withValues(alpha: 0.06),
                    cs.surface,
                  ],
                ),
              ),
            ),
          ),
        ),

        // Real app content (padded so decoration never covers it)
        Padding(
          padding: EdgeInsets.only(top: reservedTop, bottom: reservedBottom),
          child: child,
        ),

        // Top banner
        Positioned(
          left: 12,
          right: 12,
          top: topInset + 8,
          child: IgnorePointer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cs.primary, cs.primaryContainer],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: gold,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: cs.onPrimary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onPrimary.withValues(alpha: 0.92),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '🐎',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: gold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Bottom-right stamp
        Positioned(
          right: 12,
          bottom: 12 + bottomInset,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: gold.withValues(alpha: 0.85),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, size: 16, color: gold),
                  const SizedBox(width: 6),
                  Text(
                    'Chúc mừng năm mới',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
