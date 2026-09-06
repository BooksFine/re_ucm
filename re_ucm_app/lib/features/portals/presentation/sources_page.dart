import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/models/portal.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../core/di.dart';
import '../../../core/navigation/nav.dart';
import '../../../core/ui/centered_flexible_space_bar.dart';
import '../../../core/ui/tokens.dart';
import '../../../core/ui/widgets/app_search_bar.dart';
import '../../../core/ui/widgets/app_section_header.dart';
import '../../../core/ui/widgets/app_tile.dart';
import '../../downloads/presentation/widgets/downloads_indicator_button.dart';
import 'sources_controller.dart';
import 'sources_pane.dart';
import 'widgets/animated_collapse_slot.dart';
import 'widgets/source_item_tile.dart';
import 'widgets/sources_empty_view.dart';

class SourcesView {
  const SourcesView({
    required this.visible,
    required this.pinned,
    required this.other,
    required this.validCode,
    required this.isSearching,
    required this.pins,
  });

  final List<Portal> visible;
  final List<Portal> pinned;
  final List<Portal> other;
  final String? validCode;
  final bool isSearching;
  final Set<String> pins;

  factory SourcesView.resolve(
    SourcesController controller,
    List<Portal> allPortals,
  ) {
    final visible = controller.filterPortals(allPortals);
    final isSearching = controller.searchQuery.trim().isNotEmpty;
    final pins = controller.pinnedCodes.toSet();
    final pinned =
        isSearching ? const <Portal>[] : pinnedVisible(visible, pins);
    final other = isSearching ? visible : otherVisible(visible, pins);
    return SourcesView(
      visible: visible,
      pinned: pinned,
      other: other,
      validCode: controller.validSelectedCode(visible),
      isSearching: isSearching,
      pins: pins,
    );
  }
}

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

  Widget _buildFilteredPortalList(
    BuildContext context, {
    required List<Portal> allPortals,
    required EdgeInsets padding,
    required String keyPrefix,
    required AppTileChevron chevron,
    required void Function(Portal portal) onTap,
    bool Function(String code)? isSelected,
    required EdgeInsetsGeometry sectionHeaderPadding,
  }) {
    return Observer(builder: (_) {
      final view = SourcesView.resolve(_controller, allPortals);
      if (view.visible.isEmpty) {
        return const SourcesEmptyView();
      }
      final effectivePadding = view.isSearching
          ? padding.copyWith(top: 12)
          : padding;
      return _buildPortalList(
        context,
        view: view,
        padding: effectivePadding,
        keyPrefix: keyPrefix,
        chevron: chevron,
        onTap: onTap,
        isSelected: isSelected,
        sectionHeaderPadding: sectionHeaderPadding,
      );
    });
  }

  Widget _buildPortalList(
    BuildContext context, {
    required SourcesView view,
    required EdgeInsets padding,
    required String keyPrefix,
    required AppTileChevron chevron,
    required void Function(Portal portal) onTap,
    bool Function(String code)? isSelected,
    required EdgeInsetsGeometry sectionHeaderPadding,
  }) {
    final deps = AppDependencies.of(context);
    final showPinnedSection = !view.isSearching && view.pinned.isNotEmpty;

    Widget tile(
      Portal portal, {
      required String keySuffix,
      required bool isPinned,
    }) {
      final session = deps.settingsService.sessionByCode(portal.code);
      return SourceItemTile(
        key: ValueKey('${keyPrefix}_${keySuffix}_${portal.code}'),
        portal: portal,
        isAuthorized: session.isAuthorized,
        isPinned: isPinned,
        chevron: chevron,
        isSelected: isSelected?.call(portal.code) ?? false,
        onTap: () => onTap(portal),
        onTogglePin: () => _controller.togglePin(portal.code),
      );
    }

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedCollapseSlot(
            isVisible: showPinnedSection,
            child: AppSectionHeader(
              'Закрепленные (${view.pinned.length})',
              padding: sectionHeaderPadding,
            ),
          ),
          for (final portal in view.pinned)
            AnimatedCollapseSlot(
              key: ValueKey('${keyPrefix}_pinned_slot_${portal.code}'),
              isVisible: !view.isSearching,
              bottomPadding: 8,
              child: tile(portal, keySuffix: 'pin', isPinned: true),
            ),
          AnimatedCollapseSlot(
            isVisible: showPinnedSection,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: AppSectionHeader(
                'Все источники (${view.other.length})',
                padding: sectionHeaderPadding,
              ),
            ),
          ),
          for (final portal in view.other)
            AnimatedCollapseSlot(
              key: ValueKey('${keyPrefix}_other_slot_${portal.code}'),
              isVisible: true,
              bottomPadding: 8,
              child: tile(
                portal,
                keySuffix: 'item',
                isPinned: view.pins.contains(portal.code),
              ),
            ),
        ],
      ),
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
            portalListBuilder: ({
              required BuildContext context,
              required SourcesView view,
              required EdgeInsets padding,
              required String keyPrefix,
              required AppTileChevron chevron,
              required void Function(Portal portal) onTap,
              bool Function(String code)? isSelected,
              required EdgeInsetsGeometry sectionHeaderPadding,
            }) =>
                _buildPortalList(
              context,
              view: view,
              padding: padding,
              keyPrefix: keyPrefix,
              chevron: chevron,
              onTap: onTap,
              isSelected: isSelected,
              sectionHeaderPadding: sectionHeaderPadding,
            ),
          );
        }

        return _buildMobileLayout(context, allPortals);
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context, List<Portal> allPortals) {
    final bottomInset = MediaQuery.paddingOf(context).bottom + 96;

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
                child: _buildFilteredPortalList(
                  context,
                  allPortals: allPortals,
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    bottomInset,
                  ),
                  keyPrefix: 'mob',
                  chevron: AppTileChevron.show,
                  onTap: (portal) => Nav.goSourceDetails(portal.code),
                  sectionHeaderPadding: const EdgeInsets.fromLTRB(
                    AppSpacing.xs,
                    14,
                    AppSpacing.xs,
                    8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
