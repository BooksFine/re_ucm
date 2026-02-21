import 'package:flutter/material.dart';

import '../../core/navigation/router_delegate.dart';
import '../../core/ui/constants.dart';
import '../common/widgets/appbar.dart';
import '../settings/presentation/settings_dialog.dart';
import 'changelog.dart';
import 'changelog_card.dart';

class ChangelogPage extends StatelessWidget {
  const ChangelogPage({super.key});

  @override
  Widget build(BuildContext context) {
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
            onPressed: () => openSettingsDialog(context),
          ),
        ],
      ),
      body: ListView.separated(
        padding:
            const EdgeInsets.symmetric(
              horizontal: appPadding * 2,
              vertical: appPadding,
            ) +
            EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
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
