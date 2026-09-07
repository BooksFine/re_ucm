import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/models/portal.dart';

import '../../../../core/ui/tokens.dart';
import '../../../../core/ui/widgets/app_tile.dart';
import 'portal_badges.dart';
import 'portal_domain_extension.dart';
import 'portal_logo_icon.dart';

class SourceItemTile extends StatelessWidget {
  const SourceItemTile({
    super.key,
    required this.portal,
    required this.isAuthorized,
    required this.isPinned,
    required this.onTap,
    required this.onTogglePin,
    this.isSelected = false,
    this.chevron = AppTileChevron.hide,
  });

  final Portal portal;

  /// Пробрасывается сверху одним Observer на список вместо N Observer в tile.
  final bool isAuthorized;
  final bool isPinned;
  final bool isSelected;
  final AppTileChevron chevron;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final bgColor = isSelected
        ? cs.secondaryContainer.withValues(alpha: 0.5)
        : cs.surfaceContainerLowest;

    final borderColor = isSelected
        ? cs.primary
        : cs.outlineVariant.withValues(alpha: 0.5);

    // Селекция — единственный кастом: у AppTile нет selected-стиля,
    // а core/ui вне владения. Ряд/инквел/паддинги — из AppTile.
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1.0),
      ),
      child: AppTile(
        title: portal.name,
        subtitle: portal.domain,
        onTap: onTap,
        borderRadiusGeometry: AppRadii.lgRadius,
        leading: Container(
          width: 46,
          height: 46,
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: isSelected
                ? cs.surfaceContainerHighest
                : cs.surfaceContainerHighest.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: isSelected
                  ? cs.primary.withValues(alpha: 0.35)
                  : cs.outlineVariant.withValues(alpha: 0.25),
              width: isSelected ? 1.0 : 0.5,
            ),
          ),
          child: PortalLogoIcon(
            portal: portal,
            color: cs.onSurface,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (portal.supportsAuth)
              PortalAuthBadge(isAuthorized: isAuthorized),
            PortalPinIconButton(
              isPinned: isPinned,
              onTogglePin: onTogglePin,
            ),
            if (chevron == AppTileChevron.show)
              Icon(
                Icons.chevron_right_rounded,
                color: cs.onSurfaceVariant,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
