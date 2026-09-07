import 'package:material_ui/material_ui.dart';

import 'app_text_field.dart';

/// Поисковая строка. Единственный источник истины — [controller]
/// (внешний или внутренний). Раньше был второй флаг `searchQuery`,
/// дублировавший `controller.text`, плюс ручная переподписка
/// в `didUpdateWidget`.
class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    super.key,
    this.controller,
    required this.hint,
    this.onChanged,
    this.onClear,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  TextEditingController? _internalController;
  TextEditingController get _effectiveController =>
      widget.controller ?? (_internalController ??= TextEditingController());

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AppTextField(
      controller: _effectiveController,
      hint: widget.hint,
      onChanged: widget.onChanged,
      prefixIcon: Icon(
        Icons.search_rounded,
        color: cs.onSurfaceVariant,
        size: 22,
      ),
      suffixIcon: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _effectiveController,
        builder: (context, value, _) {
          if (value.text.isEmpty) {
            return const SizedBox.shrink();
          }
          return IconButton(
            icon: const Icon(Icons.clear_rounded, size: 20),
            tooltip: 'Очистить',
            onPressed: () {
              _effectiveController.clear();
              widget.onChanged?.call('');
              widget.onClear?.call();
            },
          );
        },
      ),
    );
  }
}
