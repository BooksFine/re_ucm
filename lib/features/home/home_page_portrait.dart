import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/navigation/router_delegate.dart';
import '../portals/presentation/portals_list.dart';
import '../recent_books/presentation/recent_books_list.dart';
import 'widgets/home_appbar.dart';
import 'widgets/home_expansion_panel.dart';
import 'widgets/link_forwarder.dart';

class HomePagePortrait extends StatelessWidget {
  const HomePagePortrait({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      primary: true,
      restorationId: 'Home',
      slivers: [
        const PinnedHeaderSliver(child: HomeAppbar()),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: appPadding * 2),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                const SizedBox(height: appPadding * 2),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: appPadding * 4),
                  child: LinkForwarder(),
                ),
                const SizedBox(height: appPadding * 4),
                HomeExpansionPanel(
                  title: 'Браузер',
                  icon: Icons.language,
                  child: PortalsList(
                    onTap: (portal) => Nav.goBrowser(portal.code),
                  ),
                ),
                const SizedBox(height: appPadding * 2),
                HomeExpansionPanel(
                  title: 'Последние',
                  icon: Icons.history,
                  child: RecentBooksList(),
                ),
                const SizedBox(height: appPadding * 2),
                SizedBox(height: MediaQuery.paddingOf(context).bottom),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
