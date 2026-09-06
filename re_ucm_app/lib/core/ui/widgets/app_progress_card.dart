import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';

import '../tokens.dart';

/// A standardized design-system card for displaying operation progress.
///
/// Features:
/// - Distinctive soft tinted background and border using [accentColor]
/// - Stage title and formatted status indicator (counts, percentages, or bytes)
/// - Rounded progress bar indicator
/// - Optional collapsible details section ([expandedChild]) with smooth animation
class AppProgressCard extends StatefulWidget {
  const AppProgressCard({
    super.key,
    this.title,
    this.titleWidget,
    this.statusText,
    this.statusWidget,
    this.progress,
    this.accentColor,
    this.expandedChild,
    this.initiallyExpanded = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    this.trailing,
  }) : assert(
         title != null || titleWidget != null,
         'Either title or titleWidget must be provided',
       );

  final String? title;
  final Widget? titleWidget;
  final String? statusText;
  final Widget? statusWidget;
  final double? progress;
  final Color? accentColor;
  final Widget? expandedChild;
  final bool initiallyExpanded;
  final EdgeInsetsGeometry padding;
  final Widget? trailing;

  @override
  State<AppProgressCard> createState() => _AppProgressCardState();
}

class _AppProgressCardState extends State<AppProgressCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  void _toggleExpanded() {
    if (widget.expandedChild != null) {
      setState(() => _isExpanded = !_isExpanded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = widget.accentColor ?? theme.colorScheme.primary;
    final hasDetails = widget.expandedChild != null;

    final Widget resolvedTitle =
        widget.titleWidget ??
        Text(
          widget.title!,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );

    final Widget? resolvedStatus =
        widget.statusWidget ??
        (widget.statusText != null
            ? Text(
                widget.statusText!,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null);

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.10),
          borderRadius: AppRadii.lgRadius,
          border: Border.all(
            color: accent.withValues(alpha: 0.22),
            width: 0.8,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with title, progress text, and optional toggle chevron
              InkWell(
                onTap: hasDetails ? _toggleExpanded : null,
                child: Padding(
                  padding: widget.padding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(child: resolvedTitle),
                          if (resolvedStatus != null) ...[
                            const SizedBox(width: AppSpacing.sm),
                            resolvedStatus,
                          ],
                          if (widget.trailing != null) ...[
                            const SizedBox(width: AppSpacing.xs),
                            widget.trailing!,
                          ],
                          if (hasDetails) ...[
                            const SizedBox(width: AppSpacing.xs),
                            Icon(
                              _isExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Progress bar
                      M3ELinearWavyProgressIndicator(
                        value: widget.progress,
                        color: accent,
                        backgroundColor: accent.withValues(alpha: 0.15),
                      ),
                    ],
                  ),
                ),
              ),

              // Expandable content
              if (hasDetails && _isExpanded) ...[
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: accent.withValues(alpha: 0.15),
                ),
                widget.expandedChild!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
