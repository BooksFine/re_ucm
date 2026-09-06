import 'package:material_ui/material_ui.dart';

import '../../core/navigation/router_delegate.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets/app_section_header.dart';
import '../downloads/presentation/widgets/live_download_card.dart';
import '../portals/presentation/portals_list.dart';
import '../recent_books/presentation/recent_books_list.dart';
import '../recent_books/presentation/widgets/recent_books_header.dart';
import 'widgets/link_forwarder.dart';

/// Unified Tablet & Desktop Layout (>= 780dp).
///
/// Features:
/// - Centered AppBar matching SettingsPage and mobile portrait
/// - Split-scrolling architecture:
///   - Left pane (Action Hub): Fixed in place (LinkForwarder -> PortalsList -> LiveDownloadCard).
///   - Right pane (Library): Independently scrollable recent books list with its own Scrollbar.
class HomePageLandscape extends StatefulWidget {
  const HomePageLandscape({super.key});

  @override
  State<HomePageLandscape> createState() => _HomePageLandscapeState();
}

class _HomePageLandscapeState extends State<HomePageLandscape> {
  late final ScrollController _libraryScrollController = ScrollController();
  late final ScrollController _actionHubScrollController = ScrollController();

  @override
  void dispose() {
    _libraryScrollController.dispose();
    _actionHubScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top + kToolbarHeight;
    final bottomInset = MediaQuery.paddingOf(context).bottom + 32;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Главная'),
        centerTitle: false,
        forceMaterialTransparency: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          // Proportional left pane width between 340 and 420 for optimal balance
          final leftWidth = totalWidth < 960
              ? (totalWidth * 0.40).clamp(320.0, 360.0)
              : (totalWidth * 0.35).clamp(340.0, 420.0);

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Action Hub (Input -> Portals -> Live Downloads at bottom)
                    SizedBox(
                      width: leftWidth,
                      child: Scrollbar(
                        controller: _actionHubScrollController,
                        child: SingleChildScrollView(
                          controller: _actionHubScrollController,
                          padding: EdgeInsets.only(
                            top: topInset,
                            bottom: bottomInset,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 1. Smart Link Bar
                              const LinkForwarder(),
                              const SizedBox(height: AppSpacing.lg),

                              // 2. Quick Portals (Browser) - Stable, never jumps!
                              const AppSectionHeader(
                                'Браузер',
                                padding: EdgeInsets.fromLTRB(
                                  4,
                                  0,
                                  4,
                                  AppSpacing.sm,
                                ),
                              ),
                              PortalsList(
                                onTap: (portal) => Nav.goBrowser(portal.code),
                              ),
                              const SizedBox(height: AppSpacing.md),

                              // 3. Live Downloads Card (smoothly expands below without breaking navigation)
                              const LiveDownloadCard(isWide: true),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xl),

                    // Vertical Divider
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: Theme.of(
                        context,
                      ).colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                    const SizedBox(width: AppSpacing.xl),

                    // Right Column: Recent Books Library (Independently scrollable, reaches right up to AppBar)
                    Expanded(
                      child: Scrollbar(
                        controller: _libraryScrollController,
                        child: CustomScrollView(
                          controller: _libraryScrollController,
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.only(top: topInset),
                                child: RecentBooksHeader(
                                  padding: EdgeInsets.fromLTRB(
                                    4,
                                    0,
                                    4,
                                    AppSpacing.sm,
                                  ),
                                ),
                              ),
                            ),
                            const SliverToBoxAdapter(
                              child: RecentBooksList(),
                            ),
                            SliverToBoxAdapter(
                              child: SizedBox(height: bottomInset),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
