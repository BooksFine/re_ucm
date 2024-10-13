import 'package:flutter/material.dart';
import 'package:re_ucm_core/ui/constants.dart';


class MyIconButton extends StatelessWidget {
  const MyIconButton(
      {super.key,
      required this.icon,
      required this.onTap,
      this.backgroundColor});

  final Widget icon;
  final VoidCallback onTap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      color:
          backgroundColor ?? Theme.of(context).colorScheme.secondaryContainer,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(appPadding),
          child: IconTheme(
            data: IconThemeData(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            child: icon,
          ),
        ),
      ),
    );
  }
}
