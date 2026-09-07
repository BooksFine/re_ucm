import 'package:flutter/services.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/models/portal.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';
import '../../../../core/navigation/nav.dart';
import '../../../../core/ui/tokens.dart';
import '../../../../core/ui/widgets/widgets.dart';
import '../../../common/utils/external_launcher.dart';
import '../settings/portal_settings_frame.dart';
import 'portal_badges.dart';
import 'portal_domain_extension.dart';

class SourceHeroCard extends StatelessWidget {
  const SourceHeroCard({
    super.key,
    required this.portal,
    required this.isAuth,
    required this.isPinned,
    required this.onTogglePin,
  });

  final Portal portal;
  final bool isAuth;
  final bool isPinned;
  final VoidCallback onTogglePin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PortalLogoContainer(
                  portal: portal,
                  size: 58,
                  padding: 12,
                ),
                const SizedBox(width: AppSpacing.lg),

                // Name & Domain Link
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        portal.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(AppRadii.xs),
                            onTap: () {
                              final uri = Uri.tryParse(portal.url);
                              if (uri != null) {
                                launchExternalUrl(context, uri);
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  portal.domain,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.open_in_new_rounded,
                                  size: 14,
                                  color: cs.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                          if (portal.supportsAuth) ...[
                            const SizedBox(width: 10),
                            PortalAuthBadge(isAuthorized: isAuth),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: M3EButton.icon(
                    icon: const Icon(Icons.language_rounded, size: 18),
                    label: const Text('Открыть в браузере'),
                    style: M3EButtonStyle.tonal,
                    decoration: M3EButtonDecoration.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => Nav.goBrowser(portal.code),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PortalPinScaleTransition(
                    child: isPinned
                        ? M3EButton.icon(
                            key: const ValueKey(true),
                            icon: const Icon(
                              Icons.star_rounded,
                              size: 18,
                            ),
                            label: const Text(
                              'В избранном',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: M3EButtonStyle.tonal,
                            decoration: M3EButtonDecoration.styleFrom(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              onTogglePin();
                            },
                          )
                        : M3EButton.icon(
                            key: const ValueKey(false),
                            icon: const Icon(
                              Icons.star_outline_rounded,
                              size: 18,
                            ),
                            label: const Text('Закрепить'),
                            style: M3EButtonStyle.outlined,
                            decoration: M3EButtonDecoration.styleFrom(
                              foregroundColor: cs.onSurface,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              onTogglePin();
                            },
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SourceSettingsCard extends StatelessWidget {
  const SourceSettingsCard({
    super.key,
    required this.portal,
    required this.session,
    this.isAuth = false,
  });

  final Portal portal;
  final PortalSession session;
  final bool isAuth;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, String title) = switch ((portal.supportsAuth, isAuth)) {
      (true, true) => (Icons.account_circle_rounded, 'Управление аккаунтом'),
      (true, false) => (Icons.lock_outline_rounded, 'Авторизация'),
      (false, _) => (Icons.tune_rounded, 'Параметры источника'),
    };

    return AppCard(
      icon: icon,
      titleWidget: AppCardTitle.text(title),
      children: [
        PortalSettingsFrame(
          key: ValueKey('detail_settings_${portal.code}'),
          session: session,
        ),
      ],
    );
  }
}
