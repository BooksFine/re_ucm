import 'package:material_ui/material_ui.dart';

import '../../../../../core/ui/widgets/app_counter_row.dart';

class PortalSettingsNumberField extends StatelessWidget {
  const PortalSettingsNumberField({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    this.min = 1,
    this.max = 20,
    required this.onChanged,
  });

  final String title;
  final String? subtitle;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: AppCounterRow(
        title: title,
        subtitle: subtitle,
        value: value,
        min: min,
        max: max,
        onChanged: onChanged,
      ),
    );
  }
}
