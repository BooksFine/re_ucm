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
  void initState() {
    super.initState();
    _effectiveController.addListener(_onTextChange);
  }

  @override
  void didUpdateWidget(AppSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      (oldWidget.controller ?? _internalController)
          ?.removeListener(_onTextChange);
      _effectiveController.addListener(_onTextChange);
    }
  }

  @override
  void dispose() {
    // Внешний контроллер принадлежит вызывающему — слушатель снимаем,
    // dispose делает владелец.
    _effectiveController.removeListener(_onTextChange);
    _internalController?.dispose();
    super.dispose();
  }

  void _onTextChange() {
    if (mounted) {
      setState(() {});
    }
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
      suffixIcon: _effectiveController.text.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.clear_rounded, size: 20),
              tooltip: 'Очистить',
              onPressed: () {
                _effectiveController.clear();
                widget.onChanged?.call('');
                widget.onClear?.call();
              },
            )
          : null,
    );
  }
}
