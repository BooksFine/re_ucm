import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_core/models/portal.dart';

import '../../../core/ui/tokens.dart';
import '../../../core/ui/widgets/app_tile.dart';
import 'sources_controller.dart';
import 'sources_detail_pane.dart';
import 'sources_page.dart';
import 'widgets/sources_empty_view.dart';
import 'widgets/sources_list_view.dart';

class MasterPaneHost extends StatelessWidget {
  const MasterPaneHost({
    super.key,
    required this.allPortals,
    required this.constraints,
    required this.searchBar,
    required this.masterScrollController,
    required this.controller,
  });

  final List<Portal> allPortals;
  final BoxConstraints constraints;
  final Widget searchBar;
  final ScrollController masterScrollController;
  final SourcesController controller;

  @override
  Widget build(BuildContext context) {
    final masterWidth = (constraints.maxWidth * 0.36).clamp(380.0, 480.0);
    final topInset = MediaQuery.paddingOf(context).top + kToolbarHeight;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Источники'),
        centerTitle: false,
        forceMaterialTransparency: true,
      ),
      body: Observer(
        builder: (_) {
          final view = SourcesView.resolve(controller, allPortals);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: masterWidth,
                child: MasterPane(
                  topInset: topInset,
                  searchBar: searchBar,
                  scrollController: masterScrollController,
                  listBody: view.visible.isEmpty
                      ? const SourcesEmptyView()
                      : SourcesListView(
                          view: view,
                          keyPrefix: 'master',
                          chevron: AppTileChevron.hide,
                          padding: const EdgeInsets.fromLTRB(20, 4, 12, 4),
                          sectionHeaderPadding: const EdgeInsets.only(
                            left: 4,
                            bottom: AppSpacing.sm,
                          ),
                          isSelected: (code) => code == view.validCode,
                          onTap: (portal) =>
                              controller.selectPortal(portal.code),
                          onTogglePin: controller.togglePin,
                        ),
                ),
              ),
              Expanded(
                child: DetailPane(
                  topInset: topInset,
                  view: view,
                  onTogglePin: controller.togglePin,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class MasterPane extends StatelessWidget {
  const MasterPane({
    super.key,
    required this.topInset,
    required this.searchBar,
    required this.scrollController,
    required this.listBody,
  });

  final double topInset;
  final Widget searchBar;
  final ScrollController scrollController;
  final Widget listBody;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, topInset, 12, 10),
          child: searchBar,
        ),
        Expanded(
          child: ListView(
            controller: scrollController,
            children: [
              listBody,
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }
}
