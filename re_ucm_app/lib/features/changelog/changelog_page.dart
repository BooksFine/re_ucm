import 'package:material_ui/material_ui.dart';

import '../../core/navigation/router_delegate.dart';
import '../../core/ui/tokens.dart';
import '../common/widgets/appbar.dart';
import 'changelog.dart';
import 'changelog_card.dart';

class ChangelogPage extends StatelessWidget {
  const ChangelogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= AppBreakpoints.mobileNav;

    return Scaffold(
      appBar: MyAppBar(
        title: 'История изменений',
        leading: const IconButton(
          onPressed: Nav.back,
          icon: Icon(Icons.arrow_back_ios_new),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: Nav.pushSettings,
          ),
        ],
      ),
      body: ListView.separated(
        padding: EdgeInsets.only(
          left: isWide ? 0 : AppSpacing.sm * 2,
          right: AppSpacing.sm * 2,
          top: AppSpacing.sm,
          bottom: MediaQuery.paddingOf(context).bottom,
        ),
        itemCount: changelogGen.length,
        itemBuilder: (context, index) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ChangelogCard(model: changelogGen[index]),
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 12),
      ),
    );
  }
}
