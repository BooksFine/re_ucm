import 'package:flutter/material.dart';
import 'package:re_ucm_core/ui/constants.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize = const Size.fromHeight(kToolbarHeight);

  const MyAppBar({super.key, this.title, this.leading, this.actions});

  final String? title;
  final Widget? leading;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      right: false,
      left: false,
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.titleLarge!,
        child: Container(
          height: preferredSize.height,
          padding: const EdgeInsets.symmetric(horizontal: appPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              leading != null ? leading! : const SizedBox(width: 48),
              if (title != null)
                Flexible(
                  child: Text(
                    title!,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (actions != null) Row(children: actions!),
            ],
          ),
        ),
      ),
    );
  }
}
