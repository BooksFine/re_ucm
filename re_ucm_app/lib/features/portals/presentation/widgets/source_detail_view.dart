import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/models/portal.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../../core/ui/tokens.dart';
import 'portal_domain_extension.dart';
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
    final bottomInset =
        isWide ? 24.0 : MediaQuery.paddingOf(context).bottom + 104;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Observer(
          builder: (_) {
            final isAuth = session.isAuthorized;

            final topInset = isWide
                ? MediaQuery.paddingOf(context).top + kToolbarHeight
                : 12.0;

            return ListView(
              padding: EdgeInsets.only(
                left: isWide ? 24 : 16,
                right: isWide ? 24 : 16,
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
                const SizedBox(height: 16),

                // 2. Account & Authorization Card (if portal supports auth)
                if (portal.hasAuth) ...[
                  SourceAccountCard(
                    portal: portal,
                    session: session,
                    isAuth: isAuth,
                  ),
                  const SizedBox(height: 16),
                ] else if (session.schema.isNotEmpty) ...[
                  // 3. Settings Card for portals without account auth
                  SourceSettingsCard(
                    portal: portal,
                    session: session,
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}


