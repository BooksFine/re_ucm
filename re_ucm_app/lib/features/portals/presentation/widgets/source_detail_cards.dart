import 'package:flutter/services.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/models/portal.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../../core/navigation/router_delegate.dart';
import '../../../../core/ui/app_colors_extension.dart';
import '../../../../core/ui/tokens.dart';
import '../../../../core/ui/widgets/widgets.dart';
import '../../../common/utils/external_launcher.dart';
import '../settings/portal_settings_frame.dart';
import 'portal_domain_extension.dart';
import 'portal_logo_icon.dart';

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
    final appColors = context.appColors;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Logo
                Container(
                  width: 58,
                  height: 58,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    border: Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.35),
                      width: 0.8,
                    ),
                  ),
                  child: PortalLogoIcon(
                    portal: portal,
                    color: cs.onSurface,
                  ),
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
                          if (portal.hasAuth) ...[
                            const SizedBox(width: 10),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isAuth
                                    ? appColors.statusOnline
                                    : appColors.statusOffline,
                              ),
                            ),
                            const SizedBox(width: 5),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                isAuth ? 'Подключен' : 'Без входа',
                                key: ValueKey(isAuth),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isAuth
                                      ? appColors.statusOnline
                                      : cs.onSurfaceVariant,
                                  fontWeight: isAuth
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
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
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    layoutBuilder: (currentChild, previousChildren) {
                      return Stack(
                        fit: StackFit.passthrough,
                        alignment: Alignment.center,
                        children: <Widget>[
                          ...previousChildren,
                          ?currentChild,
                        ],
                      );
                    },
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

class SourceAccountCard extends StatelessWidget {
  const SourceAccountCard({
    super.key,
    required this.portal,
    required this.session,
    required this.isAuth,
  });

  final Portal portal;
  final PortalSession session;
  final bool isAuth;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      icon: isAuth ? Icons.account_circle_rounded : Icons.lock_outline_rounded,
      title: isAuth ? 'Управление аккаунтом' : 'Авторизация',
      children: [
        PortalSettingsFrame(
          key: ValueKey('detail_auth_${portal.code}'),
          session: session,
        ),
      ],
    );
  }
}

class SourceSettingsCard extends StatelessWidget {
  const SourceSettingsCard({
    super.key,
    required this.portal,
    required this.session,
  });

  final Portal portal;
  final PortalSession session;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      icon: Icons.tune_rounded,
      title: 'Параметры источника',
      children: [
        PortalSettingsFrame(
          key: ValueKey('detail_settings_${portal.code}'),
          session: session,
        ),
      ],
    );
  }
}
