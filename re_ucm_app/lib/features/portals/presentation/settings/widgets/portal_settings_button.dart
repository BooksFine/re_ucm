import 'package:material_ui/material_ui.dart';

import '../../../../../core/ui/tokens.dart';
import '../../../../../core/ui/widgets/app_tile.dart';

class PortalSettingsButton extends StatelessWidget {
  const PortalSettingsButton({
    super.key,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.leading,
    this.trailing,
    this.isDestructive = false,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? leading;
  final Widget? trailing;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return AppTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailing,
      isDestructive: isDestructive,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      borderRadius: AppRadii.lg,
    );
  }
}
