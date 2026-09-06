import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/models/portal.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../../core/ui/tokens.dart';
import 'portal_badges.dart';
import 'portal_domain_extension.dart';
import 'portal_logo_icon.dart';

class SourceItemTile extends StatelessWidget {
  const SourceItemTile({
    super.key,
    required this.portal,
    required this.session,
    required this.isPinned,
    required this.onTap,
    required this.onTogglePin,
    this.isSelected = false,
    this.showChevron = false,
  });

  final Portal portal;
  final PortalSession session;
  final bool isPinned;
  final bool isSelected;
  final bool showChevron;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final bgColor = isSelected
        ? cs.secondaryContainer.withValues(alpha: 0.5)
        : cs.surfaceContainerLowest;

    final borderColor = isSelected
        ? cs.primary
        : cs.outlineVariant.withValues(alpha: 0.5);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          hoverColor: cs.primary.withValues(alpha: 0.08),
          splashColor: cs.primary.withValues(alpha: 0.12),
          highlightColor: cs.primary.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Logo Container
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
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
              const SizedBox(width: 14),

              // Title and status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            portal.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Observer(
                      builder: (_) {
                        if (!portal.hasAuth) {
                          return Text(
                            portal.domain,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        }

                        final isAuth = session.isAuthorized;
                        return Row(
                          children: [
                            Flexible(
                              child: Text(
                                portal.domain,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            PortalAuthBadge(
                              isAuthorized: isAuth,
                              dotSize: 5,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Pin / Favorite action
              PortalPinIconButton(
                isPinned: isPinned,
                onTogglePin: onTogglePin,
              ),

              if (showChevron)
                Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
