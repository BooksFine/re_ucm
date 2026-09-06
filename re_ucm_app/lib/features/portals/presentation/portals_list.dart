import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/models/portal.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../core/di.dart';
import '../../../core/navigation/router_delegate.dart';
import '../../../core/ui/tokens.dart';
import 'portal_card.dart';

class PortalsList extends StatelessWidget {
  const PortalsList({
    super.key,
    this.onTap,
    this.authIndication,
    this.isAuthorizedResolver,
  });

  final Function(Portal portal)? onTap;
  final bool? authIndication;
  final bool Function(Portal portal)? isAuthorizedResolver;

  @override
  Widget build(BuildContext context) {
    final deps = AppDependencies.of(context);
    final pinnedCodes = deps.settingsService.pinnedPortalCodes;
    final allPortals = PortalFactory.portals;

    // Show pinned portals on home; if none are pinned, fallback to top portals
    final displayPortals = pinnedCodes.isNotEmpty
        ? allPortals.where((p) => pinnedCodes.contains(p.code)).toList()
        : allPortals.take(4).toList();

    final itemCount = displayPortals.length + 1; // + 1 for "All sources" button

    return SizedBox(
      height: 124,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 2),
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: itemCount,
        separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (index == displayPortals.length) {
            return _AllSourcesCard(onTap: Nav.goSources);
          }

          final portal = displayPortals[index];

          Widget buildCard() => PortalCard(
            portal: portal,
            authIndication: authIndication ?? false,
            isAuthorized: isAuthorizedResolver != null
                ? isAuthorizedResolver!(portal)
                : false,
            onTap: onTap != null ? () => onTap!(portal) : null,
          );

          if (isAuthorizedResolver == null) return buildCard();

          return Observer(builder: (context) => buildCard());
        },
      ),
    );
  }
}

class _AllSourcesCard extends StatelessWidget {
  const _AllSourcesCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: BorderSide(
          color: cs.outlineVariant.withValues(alpha: 0.4),
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
                  child: Center(
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cs.surfaceContainerHighest,
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: cs.onSurface,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Все источники',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cs.onSurface,
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
