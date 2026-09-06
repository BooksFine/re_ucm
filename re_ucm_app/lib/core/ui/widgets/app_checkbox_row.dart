import 'package:material_ui/material_ui.dart';

import '../tokens.dart';
import 'app_tile.dart';

class AppCheckboxRow extends StatelessWidget {
  const AppCheckboxRow({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AppTile(
      title: title,
      subtitle: subtitle,
      enabled: enabled,
      onTap: enabled ? () => onChanged(!value) : null,
      trailing: SizedBox(
        width: 24,
        height: 24,
        child: Checkbox(
          value: value,
          onChanged: enabled ? (val) => onChanged(val ?? false) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.xs),
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}
