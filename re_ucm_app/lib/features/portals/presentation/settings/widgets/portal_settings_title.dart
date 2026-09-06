import 'package:material_ui/material_ui.dart';

class PortalSettingsTitle extends StatelessWidget {
  const PortalSettingsTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
