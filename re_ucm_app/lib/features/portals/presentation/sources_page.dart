import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/models/portal.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../core/di.dart';
import '../../../core/navigation/nav.dart';
import '../../../core/ui/centered_flexible_space_bar.dart';
import '../../../core/ui/tokens.dart';
import '../../../core/ui/widgets/app_search_bar.dart';
import '../../../core/ui/widgets/app_tile.dart';
import '../../downloads/presentation/widgets/downloads_indicator_button.dart';
import 'sources_controller.dart';
import 'sources_pane.dart';
import 'widgets/sources_empty_view.dart';
import 'widgets/sources_list_view.dart';
class SourcesPage extends StatefulWidget {
  const SourcesPage({super.key});

  @override
  State<SourcesPage> createState() => _SourcesPageState();
}

class _SourcesPageState extends State<SourcesPage> {
  late final SourcesController _controller;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _mobileScrollController = ScrollController();
  final ScrollController _masterScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final allPortals = PortalFactory.portals;
    _controller = SourcesController(
      initialCode: allPortals.isNotEmpty ? allPortals.first.code : null,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.attachSettings(AppDependencies.of(context).settingsService);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mobileScrollController.dispose();
    _masterScrollController.dispose();
    super.dispose();
  }

  Widget _buildSearchBar(List<Portal> allPortals) {
    return AppSearchBar(
      controller: _searchController,
      hint: 'Поиск по ${allPortals.length} источникам...',
      onChanged: (val) => _controller.searchQuery = val,
    );
  }

  @override
  Widget build(BuildContext context) {
    final allPortals = PortalFactory.portals;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= AppBreakpoints.sourcesSplit;

        if (isWide) {
          return MasterPaneHost(
            allPortals: allPortals,
            constraints: constraints,
            searchBar: _buildSearchBar(allPortals),
            masterScrollController: _masterScrollController,
            controller: _controller,
          );
        }

        return _buildMobileLayout(context, allPortals);
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context, List<Portal> allPortals) {
    final bottomInset =
        MediaQuery.paddingOf(context).bottom + AppSpacing.bottomBarClearance;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: CustomScrollView(
            controller: _mobileScrollController,
            slivers: [
              SliverAppBar(
                expandedHeight: 152.0,
                pinned: true,
                forceMaterialTransparency: true,
                centerTitle: true,
                flexibleSpace: const CenteredFlexibleSpaceBar(
                  title: Text('Источники'),
                  expandedTitleScale: 1.4,
                ),
                actions: const [
                  DownloadsIndicatorButton(),
                  SizedBox(width: AppSpacing.lg),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: 8,
                  ),
                  child: _buildSearchBar(allPortals),
                ),
              ),
              SliverToBoxAdapter(
                child: Observer(
                  builder: (_) {
                    final view = SourcesView.resolve(_controller, allPortals);
                    if (view.visible.isEmpty) {
                      return const SourcesEmptyView();
                    }
                    return SourcesListView(
                      view: view,
                      keyPrefix: 'mob',
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        view.isSearching ? AppSpacing.md : 0,
                        AppSpacing.lg,
                        bottomInset,
                      ),
                      sectionHeaderPadding: const EdgeInsets.fromLTRB(
                        AppSpacing.xs,
                        14,
                        AppSpacing.xs,
                        AppSpacing.sm,
                      ),
                      chevron: AppTileChevron.show,
                      onTap: (portal) => Nav.goSourceDetails(portal.code),
                      onTogglePin: _controller.togglePin,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
