import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/models/portal.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../core/di.dart';
import '../../../core/navigation/nav.dart';
import '../../../core/ui/tokens.dart';
import 'portal_card.dart';
class PortalsList extends StatelessWidget {
  const PortalsList({
    super.key,
    this.onTap,
    this.authIndication,
    this.isAuthorizedResolver,
  });

  /// Фолбэк витрины при пустых пинах (бывший магический take(4)).
  static const int kFallbackPortalCount = 4;

  final Function(Portal portal)? onTap;
  final bool? authIndication;
  final bool Function(Portal portal)? isAuthorizedResolver;

  @override
  Widget build(BuildContext context) {
    final deps = AppDependencies.of(context);
    // Один Observer сверху: пины из SettingsService читаются реактивно
    // вместе с auth-бейджами, без N Observer на карточку.
    return Observer(
      builder: (_) {
        final pinnedCodes = deps.settingsService.pinnedPortalCodes;
        final allPortals = PortalFactory.portals;

    // Show pinned portals on home; if none are pinned, fallback to top portals
    final displayPortals = pinnedCodes.isNotEmpty
        ? allPortals.where((p) => pinnedCodes.contains(p.code)).toList()
        : allPortals.take(kFallbackPortalCount).toList();

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
          return PortalCard(
            portal: portal,
            authIndication: authIndication ?? false,
            isAuthorized: isAuthorizedResolver != null
                ? isAuthorizedResolver!(portal)
                : false,
            onTap: onTap != null ? () => onTap!(portal) : null,
          );
        },
      ),
    );
      },
    );
  }
}

class _AllSourcesCard extends StatelessWidget {
  const _AllSourcesCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return PortalCardShell(
      onTap: onTap,
      label: 'Все источники',
      logo: Container(
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
    );
  }
}
