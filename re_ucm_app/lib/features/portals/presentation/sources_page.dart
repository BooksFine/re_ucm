import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/models/portal.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../core/di.dart';
import '../../../core/navigation/router_delegate.dart';
import '../../../core/ui/centered_flexible_space_bar.dart';
import '../../../core/ui/tokens.dart';
import '../../downloads/presentation/widgets/downloads_indicator_button.dart';
import 'sources_controller.dart';
import 'widgets/animated_collapse_slot.dart';
import 'widgets/source_detail_view.dart';
import 'widgets/source_item_tile.dart';
import 'widgets/sources_empty_view.dart';
import 'widgets/sources_list_section.dart';
import 'widgets/sources_search_bar.dart';

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
    final deps = AppDependencies.of(context);
    _controller.initPinnedCodes(deps.settingsService.pinnedPortalCodes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mobileScrollController.dispose();
    _masterScrollController.dispose();
    super.dispose();
  }

  void _togglePin(AppDependencies deps, String code) {
    _controller.togglePin(code, deps.settingsService.togglePinPortal);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final deps = AppDependencies.of(context);
    final allPortals = PortalFactory.portals;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 780;

        if (isWide) {
          return _buildWideLayout(context, theme, cs, deps, allPortals, constraints);
        }

        return _buildMobileLayout(context, theme, cs, deps, allPortals);
      },
    );
  }

  Widget _buildWideLayout(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    AppDependencies deps,
    List<Portal> allPortals,
    BoxConstraints constraints,
  ) {
    // Proportional width between 380 and 460 for optimal reading and breathing room
    final masterWidth = (constraints.maxWidth * 0.36).clamp(380.0, 480.0);
    final topInset = MediaQuery.paddingOf(context).top + kToolbarHeight;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Источники'),
        centerTitle: false,
        forceMaterialTransparency: true,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left pane: Master (Search + Sources List)
          SizedBox(
            width: masterWidth,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20, topInset, 12, 10),
                  child: Observer(
                    builder: (_) => SourcesSearchBar(
                      controller: _searchController,
                      totalCount: allPortals.length,
                      searchQuery: _controller.searchQuery,
                      onChanged: (val) => _controller.searchQuery = val,
                    ),
                  ),
                ),
                Expanded(
                  child: Observer(
                    builder: (_) {
                      final filteredPortals = _controller.filterPortals(allPortals);
                      final pinnedCodes = _controller.pinnedCodes;
                      final pinnedPortals = filteredPortals
                          .where((p) => pinnedCodes.contains(p.code))
                          .toList();
                      final otherPortals = filteredPortals
                          .where((p) => !pinnedCodes.contains(p.code))
                          .toList();

                      if (filteredPortals.isEmpty) {
                        return const SourcesEmptyView();
                      }

                      final validCode = filteredPortals.any((p) => p.code == _controller.selectedCode)
                          ? _controller.selectedCode
                          : filteredPortals.first.code;

                      return ListView(
                        controller: _masterScrollController,
                        padding: const EdgeInsets.fromLTRB(20, 4, 12, 4),
                        children: [
                          // Pinned section header
                          AnimatedCollapseSlot(
                            isVisible: _controller.searchQuery.isEmpty &&
                                pinnedPortals.isNotEmpty,
                            child: SourcesSectionHeader(
                              title: 'Закрепленные (${pinnedPortals.length})',
                            ),
                          ),
                          // Pinned items
                          for (final portal in allPortals)
                            AnimatedCollapseSlot(
                              key: ValueKey('master_pinned_slot_${portal.code}'),
                              isVisible: _controller.searchQuery.isEmpty &&
                                  pinnedCodes.contains(portal.code) &&
                                  filteredPortals.any((p) => p.code == portal.code),
                              bottomPadding: 8,
                              child: SourceItemTile(
                                key: ValueKey('master_pin_${portal.code}'),
                                portal: portal,
                                session: deps.settingsService
                                    .sessionByCode(portal.code),
                                isPinned: true,
                                isSelected: portal.code == validCode,
                                onTap: () => _controller.selectPortal(portal.code),
                                onTogglePin: () => _togglePin(deps, portal.code),
                              ),
                            ),
                          // Other section header
                          AnimatedCollapseSlot(
                            isVisible: _controller.searchQuery.isEmpty &&
                                pinnedPortals.isNotEmpty,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: SourcesSectionHeader(
                                title: 'Все источники (${otherPortals.length})',
                              ),
                            ),
                          ),
                          // Other / Filtered items
                          for (final portal in allPortals)
                            AnimatedCollapseSlot(
                              key: ValueKey('master_other_slot_${portal.code}'),
                              isVisible: _controller.searchQuery.isNotEmpty
                                  ? filteredPortals.any((p) => p.code == portal.code)
                                  : (!pinnedCodes.contains(portal.code) &&
                                      filteredPortals.any((p) => p.code == portal.code)),
                              bottomPadding: 8,
                              child: SourceItemTile(
                                key: ValueKey('master_${portal.code}'),
                                portal: portal,
                                session: deps.settingsService
                                    .sessionByCode(portal.code),
                                isPinned: pinnedCodes.contains(portal.code),
                                isSelected: portal.code == validCode,
                                onTap: () => _controller.selectPortal(portal.code),
                                onTogglePin: () => _togglePin(deps, portal.code),
                              ),
                            ),
                          const SizedBox(height: 32),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Right pane: Detail with smooth transition and balanced width
          Expanded(
            child: Observer(
              builder: (_) {
                final filteredPortals = _controller.filterPortals(allPortals);
                final validCode = filteredPortals.any((p) => p.code == _controller.selectedCode)
                    ? _controller.selectedCode
                    : (filteredPortals.isNotEmpty ? filteredPortals.first.code : null);

                final selectedPortal = validCode != null
                    ? filteredPortals.firstWhere((p) => p.code == validCode)
                    : null;

                final pinnedCodes = _controller.pinnedCodes;

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 0.02),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: selectedPortal == null
                      ? Center(
                          key: const ValueKey('sources_empty_detail'),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.travel_explore_rounded,
                                size: 56,
                                color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Выберите источник',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Нажмите на источник в списке слева для просмотра деталей',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        )
                      : SourceDetailView(
                          key: ValueKey(selectedPortal.code),
                          portal: selectedPortal,
                          session: deps.settingsService.sessionByCode(selectedPortal.code),
                          isPinned: pinnedCodes.contains(selectedPortal.code),
                          onTogglePin: () => _togglePin(deps, selectedPortal.code),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    AppDependencies deps,
    List<Portal> allPortals,
  ) {
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
                  child: Observer(
                    builder: (_) => SourcesSearchBar(
                      controller: _searchController,
                      totalCount: allPortals.length,
                      searchQuery: _controller.searchQuery,
                      onChanged: (val) => _controller.searchQuery = val,
                    ),
                  ),
                ),
              ),
              Observer(
                builder: (_) {
                  final filteredPortals = _controller.filterPortals(allPortals);
                  final pinnedCodes = _controller.pinnedCodes;
                  final pinnedPortals = filteredPortals
                      .where((p) => pinnedCodes.contains(p.code))
                      .toList();
                  final otherPortals = filteredPortals
                      .where((p) => !pinnedCodes.contains(p.code))
                      .toList();

                  if (filteredPortals.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: SourcesEmptyView(),
                      ),
                    );
                  }

                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        _controller.searchQuery.isNotEmpty ? 12 : 0,
                        AppSpacing.lg,
                        bottomInset,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Pinned section header
                          AnimatedCollapseSlot(
                            isVisible: _controller.searchQuery.isEmpty &&
                                pinnedPortals.isNotEmpty,
                            child: SourcesSectionHeader(
                              title: 'Закрепленные (${pinnedPortals.length})',
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.xs,
                                14,
                                AppSpacing.xs,
                                8,
                              ),
                            ),
                          ),
                          // Pinned items
                          for (final portal in allPortals)
                            AnimatedCollapseSlot(
                              key: ValueKey('mob_pinned_slot_${portal.code}'),
                              isVisible: _controller.searchQuery.isEmpty &&
                                  pinnedCodes.contains(portal.code) &&
                                  filteredPortals.any((p) => p.code == portal.code),
                              bottomPadding: 8,
                              child: SourceItemTile(
                                key: ValueKey('mob_pin_${portal.code}'),
                                portal: portal,
                                session: deps.settingsService
                                    .sessionByCode(portal.code),
                                isPinned: true,
                                showChevron: true,
                                onTap: () => Nav.goSourceDetails(portal.code),
                                onTogglePin: () => _togglePin(deps, portal.code),
                              ),
                            ),
                          // Other section header
                          AnimatedCollapseSlot(
                            isVisible: _controller.searchQuery.isEmpty &&
                                pinnedPortals.isNotEmpty,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: SourcesSectionHeader(
                                title: 'Все источники (${otherPortals.length})',
                                padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.xs,
                                  14,
                                  AppSpacing.xs,
                                  8,
                                ),
                              ),
                            ),
                          ),
                          // Other / Filtered items
                          for (final portal in allPortals)
                            AnimatedCollapseSlot(
                              key: ValueKey('mob_other_slot_${portal.code}'),
                              isVisible: _controller.searchQuery.isNotEmpty
                                  ? filteredPortals.any((p) => p.code == portal.code)
                                  : (!pinnedCodes.contains(portal.code) &&
                                      filteredPortals.any((p) => p.code == portal.code)),
                              bottomPadding: 8,
                              child: SourceItemTile(
                                key: ValueKey('mob_${portal.code}'),
                                portal: portal,
                                session: deps.settingsService
                                    .sessionByCode(portal.code),
                                isPinned: pinnedCodes.contains(portal.code),
                                showChevron: true,
                                onTap: () => Nav.goSourceDetails(portal.code),
                                onTogglePin: () => _togglePin(deps, portal.code),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
