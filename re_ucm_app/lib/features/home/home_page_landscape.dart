import 'package:material_ui/material_ui.dart';

import '../../core/ui/tokens.dart';
import '../recent_books/presentation/recent_books_list.dart';
import '../recent_books/presentation/widgets/recent_books_header.dart';
import 'widgets/home_action_hub.dart';
import 'widgets/link_forwarder_controller.dart';

/// Unified Tablet & Desktop Layout (>= 780dp).
///
/// Features:
/// - Centered AppBar matching SettingsPage and mobile portrait
/// - Split-scrolling architecture:
///   - Left pane (Action Hub): Fixed in place (LinkForwarder -> PortalsList -> LiveDownloadCard).
///   - Right pane (Library): Independently scrollable recent books list with its own Scrollbar.
class HomePageLandscape extends StatefulWidget {
  const HomePageLandscape({
    super.key,
    this.forwarderController,
    this.textController,
  });

  final LinkForwarderController? forwarderController;
  final TextEditingController? textController;

  @override
  State<HomePageLandscape> createState() => _HomePageLandscapeState();
}

/// Pure-функция ширины левой панели: 340–420 для баланса.
/// Вынесена из build, чтобы layout-константы тестировались отдельно.
double homeLeftPaneWidth(double totalWidth) {
  if (totalWidth < 960) {
    return (totalWidth * 0.40).clamp(320.0, 360.0);
  }
  return (totalWidth * 0.35).clamp(340.0, 420.0);
}

class _HomePageLandscapeState extends State<HomePageLandscape> {
  final ScrollController _libraryScrollController = ScrollController();
  final ScrollController _actionHubScrollController = ScrollController();

  @override
  void dispose() {
    _libraryScrollController.dispose();
    _actionHubScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top + kToolbarHeight;
    final bottomInset =
        MediaQuery.paddingOf(context).bottom + AppSpacing.xxl + AppSpacing.sm;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Главная'),
        centerTitle: false,
        forceMaterialTransparency: true,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final leftWidth = homeLeftPaneWidth(totalWidth);

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
                                // Action Hub: Smart Link Bar -> Portals -> Live Downloads
                                HomeActionHub(
                                  isWide: true,
                                  forwarderController: widget.forwarderController,
                                  textController: widget.textController,
                                  headerPadding: const EdgeInsets.only(
                                    bottom: AppSpacing.sm,
                                  ),
                                ),
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
                              SliverPadding(
                                padding: EdgeInsets.only(top: topInset),
                                sliver: const SliverToBoxAdapter(
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
                              SliverPadding(
                                padding: EdgeInsets.only(bottom: bottomInset),
                                sliver: const SliverToBoxAdapter(
                                  child: RecentBooksList(),
                                ),
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
      ),
    );
  }
}
