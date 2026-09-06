import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/models/portal.dart';

import '../../../core/ui/app_colors_extension.dart';
import '../../../core/ui/tokens.dart';
import 'widgets/portal_logo_icon.dart';

/// Именованные константы геометрии карточки (бывшие мэджики 110/10/2/14).
const double _kCardWidth = 110;
const double _kBadgeIconSize = 10;
const double _kBadgePadding = 2;
const double _kBadgeRightOffset = 14;

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
    final isActive = authIndication && isAuthorized;
    final body = _buildCard(context, isActive: isActive);
    if (!authIndication) return body;
    // Только opacity: раньше TweenAnimationBuilder пересобирал всё тело,
    // меняя лишь альфу цвета подписи.
    return AnimatedOpacity(
      duration: Durations.medium2,
      opacity: isActive ? 1.0 : 0.5,
      child: body,
    );
  }

  Widget _buildCard(BuildContext context, {required bool isActive}) {
    final appColors = context.appColors;
    final color = Theme.of(context).colorScheme.onSurface;

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
                    ? appColors.success
                    : appColors.statusOffline,
              ),
              child: Padding(
                padding: const EdgeInsets.all(_kBadgePadding),
                child: Icon(
                  isActive ? Icons.check : Icons.add,
                  color: Colors.white,
                  size: _kBadgeIconSize,
                ),
              ),
            )
          : null,
    );
  }
}

/// Общий каркас горизонтальной карточки портала (110px).
/// Раньше `_AllSourcesCard` в `portals_list` дублировал его 1-в-1.
/// Публичный: используется и в `portals_list` (_AllSourcesCard),
/// приватным не сделать без дублирования.
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
          width: _kCardWidth,
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
                          right: _kBadgeRightOffset,
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
