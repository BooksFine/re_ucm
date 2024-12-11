import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:re_ucm_core/ui/constants.dart';
import '../../../core/constants.dart';
import '../../common/widgets/icon_button.dart';
import '../../settings/presentation/settings_dialog.dart';

final _logoKey = GlobalKey();

class HomeAppbar extends StatelessWidget {
  const HomeAppbar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 10.0),
        child: Container(
          color:
              Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.9),
          padding: const EdgeInsets.all(appPadding * 2) +
              EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: appPadding),
                child: Image.asset(
                  key: _logoKey,
                  'lib/assets/logo.webp',
                  height: 60,
                  width: 60,
                ),
              ),
              const SizedBox(height: appPadding * 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ReUCM',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Text('v$appVersion'),
                  ],
                ),
              ),
              Hero(
                tag: 'Settings',
                createRectTween: (begin, end) {
                  return RectTween(begin: begin, end: end);
                },
                child: MyIconButton(
                  icon: const Icon(Icons.settings),
                  onTap: () => openSettingsDialog(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
