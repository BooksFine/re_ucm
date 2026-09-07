import 'package:flutter/material.dart';
import 'package:re_ucm_core/models/portal.dart';

import '../../../../core/di.dart';
import '../../../../core/ui/tokens.dart';
import '../../../../core/ui/widgets/app_section_header.dart';
import '../../../../core/ui/widgets/app_tile.dart';
import '../sources_controller.dart';
import 'animated_collapse_slot.dart';
import 'source_item_tile.dart';

class SourcesListView extends StatelessWidget {
  const SourcesListView({
    super.key,
    required this.view,
    required this.keyPrefix,
    required this.onTap,
    required this.onTogglePin,
    this.isSelected,
    this.chevron = AppTileChevron.hide,
    this.padding = EdgeInsets.zero,
    this.sectionHeaderPadding = const EdgeInsets.only(
      left: AppSpacing.xs,
      bottom: AppSpacing.sm,
    ),
  });

  final SourcesView view;
  final String keyPrefix;
  final ValueChanged<Portal> onTap;
  final ValueChanged<String> onTogglePin;
  final bool Function(String code)? isSelected;
  final AppTileChevron chevron;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry sectionHeaderPadding;

  @override
  Widget build(BuildContext context) {
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
        onTogglePin: () => onTogglePin(portal.code),
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
          AnimatedCollapseSlot(
            isVisible: showPinnedSection,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final portal in view.pinned)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: tile(portal, keySuffix: 'pin', isPinned: true),
                  ),
              ],
            ),
          ),
          if (showPinnedSection)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: AppSectionHeader(
                'Все источники (${view.other.length})',
                padding: sectionHeaderPadding,
              ),
            ),
          for (final portal in view.other)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
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
}
