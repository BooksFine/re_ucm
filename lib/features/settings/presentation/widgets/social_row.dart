import 'package:flutter/material.dart';
import 'package:re_ucm_core/ui/constants.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../../core/constants.dart';

class SocialRow extends StatelessWidget {
  const SocialRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(width: appPadding * 1.5),

        Expanded(
          flex: 3,
          child: SocialButton(
            icon: Icons.telegram,
            title: 'Telegram',
            url: telegramUrl,
          ),
        ),
        SizedBox(width: appPadding * 1.5),
        Expanded(
          flex: 2,
          child: SocialButton(
            icon: Icons.code,
            title: 'GitHub',
            url: githubUrl,
          ),
        ),
        SizedBox(width: appPadding * 1.5),
      ],
    );
  }
}

class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.icon,
    required this.title,
    required this.url,
  });

  final IconData icon;
  final String title;
  final String url;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: ColorScheme.of(context).onSurface,
        visualDensity: VisualDensity.compact,
      ),
      icon: SizedBox(height: 40, child: Icon(icon)),
      label: Text(title),
      onPressed: () =>
          launchUrlString(url, mode: LaunchMode.externalApplication),
    );
  }
}
