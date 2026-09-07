import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../core/di.dart';
import 'sources_page.dart';
import 'widgets/source_detail_view.dart';

class DetailPane extends StatelessWidget {
  const DetailPane({
    super.key,
    required this.view,
    required this.onTogglePin,
    this.topInset,
  });

  final SourcesView view;
  final void Function(String code) onTogglePin;
  final double? topInset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final deps = AppDependencies.of(context);

    final selectedPortal = view.validCode != null
        ? PortalFactory.findByCode(view.validCode!)
        : null;

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
              session:
                  deps.settingsService.sessionByCode(selectedPortal.code),
              isPinned: view.pins.contains(selectedPortal.code),
              onTogglePin: () => onTogglePin(selectedPortal.code),
              topInset: topInset,
            ),
    );
  }
}
