import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../core/di.dart';
import '../../../core/navigation/router_delegate.dart';
import 'widgets/source_detail_view.dart';

class SourceDetailPage extends StatefulWidget {
  const SourceDetailPage({super.key, required this.portalCode});

  final String portalCode;

  @override
  State<SourceDetailPage> createState() => _SourceDetailPageState();
}

class _SourceDetailPageState extends State<SourceDetailPage> {
  @override
  Widget build(BuildContext context) {
    final deps = AppDependencies.of(context);
    final portal = PortalFactory.fromCode(widget.portalCode);
    final session = deps.settingsService.sessionByCode(widget.portalCode);
    final isPinned = deps.settingsService.isPortalPinned(widget.portalCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          portal.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: Nav.back,
        ),
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: anim,
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Icon(
                isPinned ? Icons.star_rounded : Icons.star_outline_rounded,
                key: ValueKey(isPinned),
                color: isPinned ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
            tooltip: isPinned ? 'Открепить' : 'Закрепить',
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                deps.settingsService.togglePinPortal(portal.code);
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: SourceDetailView(
          portal: portal,
          session: session,
          isPinned: isPinned,
          onTogglePin: () {
            setState(() {
              deps.settingsService.togglePinPortal(portal.code);
            });
          },
        ),
      ),
    );
  }
}

