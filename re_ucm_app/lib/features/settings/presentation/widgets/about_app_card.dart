import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../core/constants.dart';
import '../../../../core/navigation/router_delegate.dart';
import '../../../../core/ui/tokens.dart';
import '../../../../core/ui/widgets/widgets.dart';

class AboutAppCard extends StatelessWidget {
  const AboutAppCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final logoLeading = Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      child: Image.asset('lib/assets/logo.webp'),
    );

    final titleWidget = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          appName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Transform.translate(
          offset: const Offset(0, -1.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: Border.all(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              'v$appVersion',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );

    final changelogBtn = _AboutActionButton(
      icon: Icons.history_rounded,
      label: 'Что нового',
      onPressed: Nav.goChangelog,
      isTonal: true,
    );

    final telegramBtn = _AboutActionButton(
      icon: Icons.telegram,
      label: 'Telegram',
      onPressed: () => launchUrlString(
        telegramUrl,
        mode: LaunchMode.externalApplication,
      ),
    );

    final githubBtn = _AboutActionButton(
      icon: Icons.code_rounded,
      label: 'GitHub',
      onPressed: () => launchUrlString(
        githubUrl,
        mode: LaunchMode.externalApplication,
      ),
    );

    return AppCard(
      leading: logoLeading,
      titleWidget: titleWidget,
      subtitle: 'Загрузка книг с сетевых библиотек',
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 480) {
              return Row(
                children: [
                  Expanded(child: changelogBtn),
                  const SizedBox(width: 10),
                  Expanded(child: telegramBtn),
                  const SizedBox(width: 10),
                  Expanded(child: githubBtn),
                ],
              );
            }

            return Column(
              children: [
                SizedBox(width: double.infinity, child: changelogBtn),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: telegramBtn),
                    const SizedBox(width: 10),
                    Expanded(child: githubBtn),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _AboutActionButton extends StatelessWidget {
  const _AboutActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isTonal = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isTonal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isTonal) {
      return M3EButton.icon(
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: M3EButtonStyle.tonal,
        decoration: M3EButtonDecoration.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: onPressed,
      );
    }

    return M3EButton.icon(
      icon: Icon(icon, size: 18, color: theme.colorScheme.onSurface),
      label: Text(label, style: TextStyle(color: theme.colorScheme.onSurface)),
      style: M3EButtonStyle.outlined,
      decoration: M3EButtonDecoration.styleFrom(
        foregroundColor: theme.colorScheme.onSurface,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onPressed,
    );
  }
}
