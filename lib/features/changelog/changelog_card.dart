import 'package:flutter/material.dart';
import 'package:re_ucm_core/ui/constants.dart';

import 'changelog.dart';

class ChangelogCard extends StatelessWidget {
  const ChangelogCard({
    super.key,
    required this.model,
  });

  final Changelog model;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(appPadding * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  model.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  model.date,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: appPadding),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: appPadding),
              child: Text(
                model.content,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
