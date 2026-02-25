import 'package:flutter/material.dart';

import '../../../../core/ui/constants.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({
    super.key,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.leading,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconThemeData(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: appPadding),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(cardBorderRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: appPadding * 2),
            child: Row(
              children: [
                if (leading != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: appPadding),
                    child: leading!,
                  ),
                const SizedBox(width: appPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                    ],
                  ),
                ),
                trailing ?? const Icon(Icons.arrow_forward_ios),
                const SizedBox(width: appPadding),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
