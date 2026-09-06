import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/models/portal.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../core/di.dart';
import '../../../core/navigation/router_delegate.dart';
import '../../../core/ui/centered_flexible_space_bar.dart';
import '../../../core/ui/tokens.dart';
import '../../../core/ui/widgets/app_search_bar.dart';
import '../../../core/ui/widgets/app_section_header.dart';
import '../../downloads/presentation/widgets/downloads_indicator_button.dart';
import 'sources_controller.dart';
import 'widgets/animated_collapse_slot.dart';
import 'widgets/source_detail_view.dart';
import 'widgets/source_item_tile.dart';
import 'widgets/sources_empty_view.dart';

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
    required bool showChevron,
    required void Function(Portal portal) onTap,
    bool Function(String code)? isSelected,
    required EdgeInsetsGeometry sectionHeaderPadding,
  }) {
    return Observer(builder: (_) {
      final visible = _controller.visiblePortals(allPortals);
      if (visible.isEmpty) {
        return const SourcesEmptyView();
      }
      // Паддинг зависит от поиска — считаем внутри Observer,
      // чтобы отступ обновлялся вместе со списком.
      final effectivePadding = _controller.searchQuery.isNotEmpty
          ? padding.copyWith(top: 12)
          : padding;
      return _buildPortalList(
        context,
        visible: visible,
        padding: effectivePadding,
        keyPrefix: keyPrefix,
        showChevron: showChevron,
        onTap: onTap,
        isSelected: isSelected,
        sectionHeaderPadding: sectionHeaderPadding,
      );
    });
  }

  Widget _buildPortalList(
    BuildContext context, {
    required List<Portal> visible,
    required EdgeInsets padding,
    required String keyPrefix,
    required bool showChevron,
    required void Function(Portal portal) onTap,
    bool Function(String code)? isSelected,
    required EdgeInsetsGeometry sectionHeaderPadding,
  }) {
    final deps = AppDependencies.of(context);
    // Партиционирование уже посчитано вызывающим — здесь только рендер.
    final pinnedPortals = _controller.pinnedVisible(visible);
    final otherPortals = _controller.otherVisible(visible);
    final showPinnedSection =
        _controller.searchQuery.isEmpty && pinnedPortals.isNotEmpty;

    Widget tile(
      Portal portal, {
      required String keySuffix,
      required bool isPinned,
    }) {
      return SourceItemTile(
        key: ValueKey('${keyPrefix}_${keySuffix}_${portal.code}'),
        portal: portal,
        session: deps.settingsService.sessionByCode(portal.code),
        isPinned: isPinned,
        showChevron: showChevron,
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
              'Закрепленные (${pinnedPortals.length})',
              padding: sectionHeaderPadding,
            ),
          ),
          for (final portal in pinnedPortals)
            AnimatedCollapseSlot(
              key: ValueKey('${keyPrefix}_pinned_slot_${portal.code}'),
              isVisible:
                  _controller.searchQuery.isEmpty, // скрытие — анимацией
              bottomPadding: 8,
              child: tile(portal, keySuffix: 'pin', isPinned: true),
            ),
          AnimatedCollapseSlot(
            isVisible: showPinnedSection,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: AppSectionHeader(
                'Все источники (${otherPortals.length})',
                padding: sectionHeaderPadding,
              ),
            ),
          ),
          for (final portal in (_controller.searchQuery.isNotEmpty
              ? visible
              : otherPortals))
            AnimatedCollapseSlot(
              key: ValueKey('${keyPrefix}_other_slot_${portal.code}'),
              isVisible: true,
              bottomPadding: 8,
              child: tile(
                portal,
                keySuffix: 'item',
                isPinned: _controller.pinnedCodes.contains(portal.code),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final deps = AppDependencies.of(context);
    final allPortals = PortalFactory.portals;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= AppBreakpoints.sourcesSplit;

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
                  child: _buildSearchBar(allPortals),
                ),
                Expanded(
                  child: Observer(
                    builder: (_) {
                      final visible = _controller.visiblePortals(allPortals);
                      if (visible.isEmpty) {
                        return const SourcesEmptyView();
                      }

                      final validCode =
                          _controller.validSelectedCode(visible);

                      return ListView(
                        controller: _masterScrollController,
                        children: [
                          _buildPortalList(
                            context,
                            visible: visible,
                            padding: const EdgeInsets.fromLTRB(20, 4, 12, 4),
                            keyPrefix: 'master',
                            showChevron: false,
                            isSelected: (code) => code == validCode,
                            onTap: (portal) => _controller.selectPortal(portal.code),
                            sectionHeaderPadding: const EdgeInsets.only(left: 4, bottom: 8),
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
                final visible = _controller.visiblePortals(allPortals);
                final validCode = _controller.validSelectedCode(visible);

                final selectedPortal = validCode != null
                    ? visible.firstWhere((p) => p.code == validCode)
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
                          onTogglePin: () =>
                              _controller.togglePin(selectedPortal.code),
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
                  showChevron: true,
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
