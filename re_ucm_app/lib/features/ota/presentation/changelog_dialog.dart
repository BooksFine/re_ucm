import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/navigation/router_delegate.dart';
import '../../../core/ui/tokens.dart';
import '../../changelog/changelog.dart';

class ChangelogDialog extends StatelessWidget {
  const ChangelogDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm * 2,
        vertical: AppSpacing.sm * 6,
      ),
      title: Text(changelogGen[0].title),
      titleTextStyle: Theme.of(context).textTheme.headlineMedium,
      content: Text(changelogGen[0].content),
      actions: [
        SizedBox(
          width: double.infinity,
          child: M3EButton(
            style: M3EButtonStyle.outlined,
            size: M3EButtonSize.md,
            onPressed: () {
              Nav.back();
              Nav.goChangelog();
            },
            child: const Text('Полный список'),
          ),
        ),
      ],
    );
  }
}
