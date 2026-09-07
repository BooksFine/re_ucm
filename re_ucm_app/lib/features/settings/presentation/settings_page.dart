import 'package:material_ui/material_ui.dart';

import '../../../core/navigation/nav.dart';
import '../../../core/ui/centered_flexible_space_bar.dart';
import '../../../core/ui/tokens.dart';
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
  late final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktopNav = screenWidth >= AppBreakpoints.mobileNav;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTwoColumn =
            constraints.maxWidth >= AppBreakpoints.sourcesSplit;
        final bottomInset = MediaQuery.paddingOf(context).bottom +
            (!widget.isEmbedded || isDesktopNav
                ? AppSpacing.xxl
                : AppSpacing.bottomBarClearance);

        const leftCards = [
          StorageSettingsCard(),
          SizedBox(height: AppSpacing.lg),
          DownloadSettingsCard(),
        ];
        const rightCards = [
          PathTemplatesCard(),
          SizedBox(height: AppSpacing.lg),
          AuthorsSeparatorCard(),
          SizedBox(height: AppSpacing.lg),
          AboutAppCard(),
        ];

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
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
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
                        const SizedBox(width: AppSpacing.lg),
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
              constraints: const BoxConstraints(maxWidth: 720),
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
                        left: AppSpacing.lg,
                        right: AppSpacing.lg,
                        top: AppSpacing.sm,
                        bottom: bottomInset,
                      ),
                      sliver: SliverList.list(
                        children: [
                          ...leftCards,
                          const SizedBox(height: AppSpacing.lg),
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
