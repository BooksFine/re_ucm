import 'package:material_ui/material_ui.dart';

import '../../../core/di.dart';
import '../../../core/navigation/nav.dart';
import '../../../core/ui/centered_flexible_space_bar.dart';
import 'settings_controller.cg.dart';
import 'widgets/about_app_card.dart';
import 'widgets/authors_separator_card.dart';
import 'widgets/download_settings_card.dart';
import 'widgets/path_templates_card.dart';
import 'widgets/storage_settings_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    this.isEmbedded = false,
  });

  final bool isEmbedded;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SettingsController controller;

  @override
  void didChangeDependencies() {
    final newController = AppDependencies.of(context).settingsController;
    if (_leftCards == null || !identical(controller, newController)) {
      controller = newController;
      _leftCards = null;
      _rightCards = null;
    }
    super.didChangeDependencies();
  }

  late final ScrollController _scrollController = ScrollController();

  // Мемоизация списков карточек: контроллер стабилен после
  // didChangeDependencies, пересобирать списки на каждый build ни к чему.
  List<Widget>? _leftCards;
  List<Widget>? _rightCards;

  List<Widget> _getLeftCards() => _leftCards ??= [
        StorageSettingsCard(controller: controller),
        const SizedBox(height: 16),
        DownloadSettingsCard(controller: controller),
      ];

  List<Widget> _getRightCards() => _rightCards ??= [
        PathTemplatesCard(controller: controller),
        const SizedBox(height: 16),
        AuthorsSeparatorCard(controller: controller),
        const SizedBox(height: 16),
        const AboutAppCard(),
      ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktopNav = screenWidth >= 600;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTwoColumn = constraints.maxWidth >= 780;
        final bottomInset =
            MediaQuery.paddingOf(context).bottom +
            (!widget.isEmbedded || isDesktopNav ? 24 : 96);

        final leftCards = _getLeftCards();
        final rightCards = _getRightCards();

        // ── Wide / landscape layout ──────────────────────────────────────
        if (isTwoColumn) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: const Text('Настройки'),
              centerTitle: false,
              forceMaterialTransparency: true,
              leading: !widget.isEmbedded && Navigator.canPop(context)
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new),
                      onPressed: Nav.back,
                    )
                  : null,
            ),
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Scrollbar(
                  controller: _scrollController,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: MediaQuery.paddingOf(context).top + kToolbarHeight,
                      bottom: bottomInset,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: leftCards,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: rightCards,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        // ── Portrait layout ──────────────────────────────────────────────
        return Scaffold(
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Scrollbar(
                controller: _scrollController,
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 152.0,
                      pinned: true,
                      forceMaterialTransparency: true,
                      centerTitle: true,
                      leading: !widget.isEmbedded && Navigator.canPop(context)
                          ? IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new),
                              onPressed: Nav.back,
                            )
                          : null,
                      flexibleSpace: const CenteredFlexibleSpaceBar(
                        title: Text('Настройки'),
                        expandedTitleScale: 1.4,
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 8,
                        bottom: bottomInset,
                      ),
                      sliver: SliverList.list(
                        children: [
                          ...leftCards,
                          const SizedBox(height: 16),
                          ...rightCards,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
