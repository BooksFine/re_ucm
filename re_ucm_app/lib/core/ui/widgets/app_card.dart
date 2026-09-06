import 'package:material_ui/material_ui.dart';

import '../tokens.dart';
import 'app_icon_container.dart';

/// Канонический билдер заголовков для [AppCard]/[AppProgressCard].
///
/// Новый код передаёт виджеты (`title: AppCardTitle.text('...')`),
/// строки напрямую больше не принимаются.
class AppCardTitle extends StatelessWidget {
  /// Заголовок в стиле карточки (titleMedium, bold).
  const AppCardTitle.text(
    this.data, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  final String data;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      data,
      style:
          style ??
          theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}

class AppCardSubtitle extends StatelessWidget {
  const AppCardSubtitle({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  /// Канонический конструктор: заголовки — виджеты
  /// (`titleWidget`/`subtitleWidget`/`statusWidget`, например `AppCardTitle.text('...')`).
  const AppCard({
    super.key,
    this.icon,
    this.leading,
    this.titleWidget,
    this.subtitleWidget,
    this.statusWidget,
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
  final Widget? titleWidget;
  final Widget? subtitleWidget;

  /// Статусная строка под subtitle. Новый слот, по умолчанию отсутствует.
  final Widget? statusWidget;
  final Widget? trailing;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsetsGeometry padding;
  final double headerSpacing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final resolvedLeading =
        leading ?? (icon != null ? AppIconContainer(icon: icon!) : null);

    final hasHeader =
        resolvedLeading != null ||
        titleWidget != null ||
        subtitleWidget != null ||
        statusWidget != null ||
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
                        ?titleWidget,
                        ?subtitleWidget,
                      ],
                    ),
                  ),
                  ?trailing,
                ],
              ),
              if (statusWidget != null) ...[
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: statusWidget!,
                ),
              ],
              SizedBox(height: headerSpacing),
            ],
            ...children,
          ],
        ),
      ),
    );
  }
}
