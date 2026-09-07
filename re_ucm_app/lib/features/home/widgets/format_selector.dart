import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

/// Выбор формата сохранения: `EPUB / FB2 / FB2.ZIP`.
/// Использует SegmentedButton с темой из segmentedButtonTheme.
class FormatSelector extends StatelessWidget {
  const FormatSelector({
    super.key,
    required this.current,
    required this.onSelected,
  });

  final SaveFormat current;
  final ValueChanged<SaveFormat> onSelected;

  static const _formats = SaveFormat.displayValues;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<SaveFormat>(
      showSelectedIcon: false,
      segments: [
        for (final fmt in _formats)
          ButtonSegment<SaveFormat>(
            value: fmt,
            label: Text(
              fmt.label.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
      ],
      selected: {current},
      onSelectionChanged: (selected) {
        if (selected.isNotEmpty) {
          onSelected(selected.first);
        }
      },
    );
  }
}
