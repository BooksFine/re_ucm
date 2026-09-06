import 'package:material_ui/material_ui.dart';

import '../tokens.dart';
import 'app_icon_container.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    this.icon,
    this.leading,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.trailing,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.headerSpacing = AppSpacing.lg,
    required this.children,
  }) : assert(
         icon == null || leading == null,
         'Cannot provide both icon and leading',
       );

  final IconData? icon;
  final Widget? leading;
  final String? title;
  final Widget? titleWidget;
  final String? subtitle;
  final Widget? subtitleWidget;
  final Widget? trailing;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsetsGeometry padding;
  final double headerSpacing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final resolvedLeading =
        leading ?? (icon != null ? AppIconContainer(icon: icon!) : null);

    final hasHeader =
        resolvedLeading != null ||
        title != null ||
        titleWidget != null ||
        subtitle != null ||
        subtitleWidget != null ||
        trailing != null;

    return Card(
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          children: [
            if (hasHeader) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (resolvedLeading != null) ...[
                    resolvedLeading,
                    const SizedBox(width: AppSpacing.md),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (titleWidget != null)
                          titleWidget!
                        else if (title != null)
                          Text(
                            title!,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (subtitleWidget != null)
                          subtitleWidget!
                        else if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  ?trailing,
                ],
              ),
              SizedBox(height: headerSpacing),
            ],
            ...children,
          ],
        ),
      ),
    );
  }
}
