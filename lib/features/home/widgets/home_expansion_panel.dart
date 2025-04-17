import 'package:flutter/material.dart';
import 'package:re_ucm_core/ui/constants.dart';

class HomeExpansionPanel extends StatelessWidget {
  const HomeExpansionPanel({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(cardBorderRadius),
      ),
      padding: const EdgeInsets.all(appPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(appPadding),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
          const SizedBox(height: appPadding),
          child,
          const SizedBox(height: appPadding),
        ],
      ),
    );
  }
}
