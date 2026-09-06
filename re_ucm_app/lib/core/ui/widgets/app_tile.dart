import 'package:material_ui/material_ui.dart';

import '../tokens.dart';

/// Режим отображения chevron в [AppTile].
enum AppTileChevron {
  /// Легаси-поведение: показать, если tile интерактивен и нет [AppTile.trailing].
  auto,

  /// Принудительно показать (когда нет [AppTile.trailing]).
  show,

  /// Никогда не показывать.
  hide,
}

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
    this.chevron = AppTileChevron.auto,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.xs,
      vertical: 6,
    ),
    this.borderRadiusGeometry,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;
  final bool isDestructive;

  /// Канонический режим chevron. [AppTileChevron.auto] показывает chevron
  /// для интерактивного tile без [trailing].
  final AppTileChevron chevron;
  final EdgeInsetsGeometry contentPadding;

  /// Канонический радиус.
  final BorderRadius? borderRadiusGeometry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isInteractive = enabled && onTap != null;

    final Color titleColor;
    if (!enabled) {
      titleColor = cs.onSurface.withValues(alpha: AppOpacity.disabled);
    } else if (isDestructive) {
      titleColor = cs.error;
    } else {
      titleColor = cs.onSurface;
    }

    final Color subtitleColor;
    if (!enabled) {
      subtitleColor = cs.onSurfaceVariant.withValues(
        alpha: AppOpacity.disabled,
      );
    } else if (isDestructive) {
      subtitleColor = cs.error.withValues(alpha: AppOpacity.strong);
    } else {
      subtitleColor = cs.onSurfaceVariant;
    }

    final bool effectiveShowChevron = switch (chevron) {
      AppTileChevron.show => trailing == null,
      AppTileChevron.hide => false,
      AppTileChevron.auto => isInteractive && trailing == null,
    };

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
                    ? cs.error.withValues(alpha: AppOpacity.emphasized)
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

    final resolvedBorderRadius = borderRadiusGeometry ?? AppRadii.mdRadius;

    return InkWell(
      onTap: isInteractive ? onTap : null,
      borderRadius: resolvedBorderRadius,
      child: Padding(
        padding: contentPadding,
        child: content,
      ),
    );
  }
}
