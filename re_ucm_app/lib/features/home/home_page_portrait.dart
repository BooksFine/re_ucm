import 'package:material_ui/material_ui.dart';

import '../../core/navigation/router_delegate.dart';
import '../../core/ui/centered_flexible_space_bar.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets/app_section_header.dart';
import '../downloads/presentation/widgets/live_download_card.dart';
import '../portals/presentation/portals_list.dart';
import '../recent_books/presentation/recent_books_list.dart';
import '../recent_books/presentation/widgets/recent_books_header.dart';
import 'widgets/link_forwarder.dart';

class HomePagePortrait extends StatefulWidget {
  const HomePagePortrait({super.key});

  @override
  State<HomePagePortrait> createState() => _HomePagePortraitState();
}

class _HomePagePortraitState extends State<HomePagePortrait> {
  late final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasBottomBar = MediaQuery.sizeOf(context).width < 600;
    final bottomInset =
        MediaQuery.paddingOf(context).bottom + (hasBottomBar ? 104 : 24);

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // M3 Large Title App Bar (152dp, smooth collapse on scroll, centered title)
                const SliverAppBar(
                  expandedHeight: 152.0,
                  pinned: true,
                  forceMaterialTransparency: true,
                  centerTitle: true,
                  flexibleSpace: CenteredFlexibleSpaceBar(
                    title: Text('Главная'),
                    expandedTitleScale: 1.4,
                  ),
                ),

                // Action Zone: Smart Link Bar
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      8,
                      AppSpacing.lg,
                      AppSpacing.sm,
                    ),
                    child: LinkForwarder(),
                  ),
                ),

                // Quick Sources Section (horizontal carousel directly on page)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppSectionHeader(
                          'Браузер',
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            0,
                            AppSpacing.lg,
                            AppSpacing.sm,
                          ),
                        ),
                        PortalsList(
                          onTap: (portal) => Nav.goBrowser(portal.code),
                        ),
                      ],
                    ),
                  ),
                ),

                // Live Downloads Card (located below portals, smoothly expands when downloads active)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      0,
                    ),
                    child: LiveDownloadCard(isWide: false),
                  ),
                ),

                // Recent Books Section Header
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.xl,
                      AppSpacing.lg,
                      AppSpacing.xs,
                    ),
                    child: RecentBooksHeader(padding: EdgeInsets.zero),
                  ),
                ),

                // Recent Books List (unboxed, breathing freely on page background)
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.xs,
                    AppSpacing.lg,
                    bottomInset,
                  ),
                  sliver: const SliverToBoxAdapter(
                    child: RecentBooksList(isWide: false),
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
