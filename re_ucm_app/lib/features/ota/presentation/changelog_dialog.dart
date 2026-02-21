import 'package:flutter/material.dart';

import '../../../core/navigation/router_delegate.dart';
import '../../../core/ui/constants.dart';
import '../../changelog/changelog.dart';
import '../../common/widgets/outlined_btn.dart';

class ChangelogDialog extends StatelessWidget {
  const ChangelogDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: appPadding * 2,
        vertical: appPadding * 6,
      ),
      title: Text(changelogGen[0].title),
      titleTextStyle: Theme.of(context).textTheme.headlineMedium,
      content: Text(changelogGen[0].content),
      actions: [
        SizedBox(
          height: 54,
          child: OutlinedButton1(
            text: 'Полный список',
            func: () {
              Nav.back();
              Nav.goChangelog();
            },
          ),
        ),
      ],
    );
  }
}
