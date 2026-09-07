import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/models/portal.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../../core/ui/tokens.dart';
import 'source_detail_cards.dart';

class SourceDetailView extends StatelessWidget {
  const SourceDetailView({
    super.key,
    required this.portal,
    required this.session,
    required this.isPinned,
    required this.onTogglePin,
  });

  final Portal portal;
  final PortalSession session;
  final bool isPinned;
  final VoidCallback onTogglePin;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= AppBreakpoints.mobileNav;
    // Ensure floating bottom NavBar never covers content on mobile
    final bottomInset = isWide
        ? AppSpacing.xxl
        : MediaQuery.paddingOf(context).bottom + AppSpacing.bottomBarClearance;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Observer(
          builder: (_) {
            final isAuth = session.isAuthorized;

            final topInset = isWide
                ? MediaQuery.paddingOf(context).top + kToolbarHeight
                : AppSpacing.md;

            return ListView(
              padding: EdgeInsets.only(
                left: isWide ? AppSpacing.xxl : AppSpacing.lg,
                right: isWide ? AppSpacing.xxl : AppSpacing.lg,
                top: topInset,
                bottom: bottomInset,
              ),
              children: [
                // 1. Hero / Overview Card
                SourceHeroCard(
                  portal: portal,
                  isAuth: isAuth,
                  isPinned: isPinned,
                  onTogglePin: onTogglePin,
                ),
                const SizedBox(height: AppSpacing.lg),

                // 2. Settings & Account Card
                if (session.schema.isNotEmpty) ...[
                  SourceSettingsCard(
                    portal: portal,
                    session: session,
                    isAuth: isAuth,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}


