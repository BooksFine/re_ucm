import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/models/portal.dart';

import '../../../core/ui/app_colors_extension.dart';
import '../../../core/ui/tokens.dart';
import 'widgets/portal_logo_icon.dart';

class PortalCard extends StatelessWidget {
  const PortalCard({
    super.key,
    required this.portal,
    this.onTap,
    this.authIndication = false,
    required this.isAuthorized,
  });

  final Portal portal;
  final VoidCallback? onTap;
  final bool authIndication;
  final bool isAuthorized;

  @override
  Widget build(BuildContext context) {
    if (authIndication) {
      final isActive = isAuthorized;
      return TweenAnimationBuilder<double>(
        duration: Durations.medium2,
        tween: Tween<double>(
          begin: isActive ? 0.5 : 1,
          end: isActive ? 1 : 0.5,
        ),
        builder: (_, v, child) {
          final color = Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: v);
          return _buildCard(context, color: color, isActive: isActive);
        },
      );
    }
    return _buildCard(
      context,
      color: Theme.of(context).colorScheme.onSurface,
      isActive: false,
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required Color color,
    required bool isActive,
  }) {
    final appColors = context.appColors;

    return PortalCardShell(
      onTap: onTap,
      label: portal.name,
      labelColor: color,
      logo: PortalLogoIcon(
        portal: portal,
        color: color,
        opacity: isActive || !authIndication ? 1.0 : 0.5,
      ),
      badge: authIndication
          ? Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? appColors.statusOnline
                    : appColors.statusOffline,
              ),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(
                  isActive ? Icons.check : Icons.add,
                  color: Colors.white,
                  size: 10,
                ),
              ),
            )
          : null,
    );
  }
}

/// Общий каркас горизонтальной карточки портала (110px).
/// Раньше `_AllSourcesCard` в `portals_list` дублировал его 1-в-1.
class PortalCardShell extends StatelessWidget {
  const PortalCardShell({
    super.key,
    required this.logo,
    required this.label,
    this.labelColor,
    this.badge,
    this.onTap,
  });

  final Widget logo;
  final String label;
  final Color? labelColor;
  final Widget? badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = labelColor ?? theme.colorScheme.onSurface;
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: 0.8,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: SizedBox(
          width: 110,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: AppSpacing.xs,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(child: logo),
                      if (badge != null)
                        Positioned(
                          right: 14,
                          bottom: 0,
                          child: badge!,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
