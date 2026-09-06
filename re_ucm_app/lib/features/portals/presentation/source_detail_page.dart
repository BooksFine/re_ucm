import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../core/di.dart';
import '../../../core/navigation/nav.dart';
import 'widgets/portal_badges.dart';
import 'widgets/source_detail_view.dart';

class SourceDetailPage extends StatefulWidget {
  const SourceDetailPage({super.key, required this.portalCode});

  final String portalCode;

  @override
  State<SourceDetailPage> createState() => _SourceDetailPageState();
}

class _SourceDetailPageState extends State<SourceDetailPage> {
  void _togglePin(SettingsService settings, String code) {
    // setState оставлен: SettingsService не Store, Observer ниже
    // станет реактивным только после его миграции (TODO).
    setState(() => settings.togglePinPortal(code));
  }

  @override
  Widget build(BuildContext context) {
    final deps = AppDependencies.of(context);
    final portal = PortalFactory.findByCode(widget.portalCode);
    if (portal == null) {
      return Scaffold(
        appBar: AppBar(leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: Nav.back,
        )),
        body: Center(
          child: Text('Источник «${widget.portalCode}» не найден'),
        ),
      );
    }
    // Один Observer на страницу: isPinned читается один раз за билд,
    // один onTogglePin-замыкание переиспользуется в AppBar и body.
    return Observer(
      builder: (_) {
        final isPinned = deps.settingsService.isPortalPinned(portal.code);
        final session =
            deps.settingsService.sessionByCodeOrNull(widget.portalCode);
        void onTogglePin() => _togglePin(deps.settingsService, portal.code);

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
              PortalPinIconButton(
                isPinned: isPinned,
                onTogglePin: onTogglePin,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            bottom: false,
            child: session == null
                ? const Center(child: Text('Сессия источника не найдена'))
                : SourceDetailView(
                    portal: portal,
                    session: session,
                    isPinned: isPinned,
                    onTogglePin: onTogglePin,
                  ),
          ),
        );
      },
    );
  }
}
