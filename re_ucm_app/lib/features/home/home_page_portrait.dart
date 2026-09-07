import 'package:material_ui/material_ui.dart';

import '../../core/ui/centered_flexible_space_bar.dart';
import '../../core/ui/tokens.dart';
import '../recent_books/presentation/recent_books_list.dart';
import '../recent_books/presentation/widgets/recent_books_header.dart';
import 'widgets/home_action_hub.dart';
import 'widgets/link_forwarder_controller.dart';

class HomePagePortrait extends StatefulWidget {
  const HomePagePortrait({
    super.key,
    this.forwarderController,
    this.textController,
  });

  final LinkForwarderController? forwarderController;
  final TextEditingController? textController;

  @override
  State<HomePagePortrait> createState() => _HomePagePortraitState();
}

class _HomePagePortraitState extends State<HomePagePortrait> {
  final ScrollController _scrollController = ScrollController();

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

                // Action Hub: Smart Link Bar -> Portals -> Live Downloads
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: AppSpacing.sm),
                    child: HomeActionHub(
                      isWide: false,
                      forwarderController: widget.forwarderController,
                      textController: widget.textController,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      headerPadding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.sm,
                      ),
                    ),
                  ),
                ),

                // Recent Books Section (header + list, unboxed)
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.xs,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: RecentBooksHeader(),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.xs,
                    AppSpacing.lg,
                    bottomInset,
                  ),
                  sliver: const SliverToBoxAdapter(
                    child: RecentBooksList(),
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
