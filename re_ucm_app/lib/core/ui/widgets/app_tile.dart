import 'package:material_ui/material_ui.dart';

import '../tokens.dart';

class AppTile extends StatelessWidget {
  const AppTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.isDestructive = false,
    this.showChevron,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.xs,
      vertical: 6,
    ),
    this.borderRadius,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;
  final bool isDestructive;
  final bool? showChevron;
  final EdgeInsetsGeometry contentPadding;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isInteractive = enabled && onTap != null;

    final Color titleColor;
    if (!enabled) {
      titleColor = cs.onSurface.withValues(alpha: 0.38);
    } else if (isDestructive) {
      titleColor = cs.error;
    } else {
      titleColor = cs.onSurface;
    }

    final Color subtitleColor;
    if (!enabled) {
      subtitleColor = cs.onSurfaceVariant.withValues(alpha: 0.38);
    } else if (isDestructive) {
      subtitleColor = cs.error.withValues(alpha: 0.8);
    } else {
      subtitleColor = cs.onSurfaceVariant;
    }

    final effectiveShowChevron =
        showChevron ?? (isInteractive && trailing == null);

    final titleColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(color: subtitleColor),
          ),
        ],
      ],
    );

    // Один Row вместо двух деревьев: раньше ветка <250px дублировала
    // всё дерево ради редкого кейса, а каждый tile в списке платил
    // за LayoutBuilder. Trailing — без flex-обёртки: Flexible делил бы
    // свободное место с Expanded и уводил trailing к центру.
    final resolvedTrailing = trailing ??
        (effectiveShowChevron
            ? Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isDestructive
                    ? cs.error.withValues(alpha: 0.7)
                    : cs.onSurfaceVariant,
              )
            : null);

    final content = Row(
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: AppSpacing.md),
        ],
        Expanded(child: titleColumn),
        if (resolvedTrailing != null) ...[
          const SizedBox(width: AppSpacing.md),
          resolvedTrailing,
        ],
      ],
    );

    return InkWell(
      onTap: isInteractive ? onTap : null,
      borderRadius: BorderRadius.circular(borderRadius ?? AppRadii.md),
      child: Padding(
        padding: contentPadding,
        child: content,
      ),
    );
  }
}
