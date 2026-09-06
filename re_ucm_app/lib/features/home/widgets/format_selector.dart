import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../core/ui/tokens.dart';

/// Выбор формата сохранения: `EPUB / FB2 / FB2.ZIP`.
/// Вынесен из LinkForwarder, чтобы превью не знало про ChoiceChip.
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Формат: ',
          style: theme.textTheme.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        for (final fmt in _formats) ...[
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: ChoiceChip(
              label: Text(fmt.label.toUpperCase()),
              labelStyle: TextStyle(
                fontSize: 11,
                fontWeight: fmt == current
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
              selected: fmt == current,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.full),
              ),
              onSelected: (selected) {
                if (selected) onSelected(fmt);
              },
            ),
          ),
        ],
      ],
    );
  }
}
