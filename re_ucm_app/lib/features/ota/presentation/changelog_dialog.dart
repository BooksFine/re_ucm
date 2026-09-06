import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/navigation/nav.dart';
import '../../../core/ui/tokens.dart';
import '../../changelog/changelog.dart';
import '../../common/widgets/app_button.dart';

class ChangelogDialog extends StatelessWidget {
  const ChangelogDialog({super.key});

  @override
  Widget build(BuildContext context) {
    if (changelogGen.isEmpty) return const SizedBox.shrink();
    final entry = changelogGen.first;
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xxl * 3,
      ),
      title: Text(entry.title),
      titleTextStyle: Theme.of(context).textTheme.headlineMedium,
      content: SingleChildScrollView(child: Text(entry.content)),
      actions: [
        AppButton(
          style: M3EButtonStyle.outlined,
          onPressed: () {
            Nav.back();
            Nav.goChangelog();
          },
          child: const Text('Полный список'),
        ),
      ],
    );
  }
}
