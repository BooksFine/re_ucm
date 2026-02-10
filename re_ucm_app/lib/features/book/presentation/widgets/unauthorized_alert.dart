import 'package:flutter/material.dart';
import 'package:re_ucm_core/re_ucm_core.dart';

import '../../../../core/navigation/router_delegate.dart';

class UnauthorizedAlert extends StatelessWidget {
  const UnauthorizedAlert({super.key, required this.portal});

  final String portal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: appPadding),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: Nav.pushSettings,
        title: Text(
          'Внимание, вы не авторизованы',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: ColorScheme.of(
                context,
              ).onPrimaryContainer.withValues(alpha: 0.8),
            ),
            children: [
              const TextSpan(
                text:
                    'Будут загружены только бесплатные главы. Чтобы скачать закрытые части, войдите в аккаунт ',
              ),
              TextSpan(
                text: portal,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ColorScheme.of(context).onSurface,
                ),
              ),
              const TextSpan(text: ' в настройках'),
            ],
          ),
        ),
      ),
    );
  }
}
