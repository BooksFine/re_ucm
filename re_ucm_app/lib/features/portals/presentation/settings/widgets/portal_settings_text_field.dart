import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../../core/ui/tokens.dart';

/// Текстовое поле настроек портала с заголовком и асинхронной кнопкой
/// применения/сохранения со спиннером.
class PortalSettingsTextField extends StatefulWidget {
  const PortalSettingsTextField({
    super.key,
    this.title,
    this.initialValue,
    required this.hint,
    this.onSubmit,
    this.onChanged,
  });

  final String? title;
  final String? initialValue;
  final String hint;
  final Future<void> Function(String value)? onSubmit;
  final ValueChanged<String>? onChanged;

  @override
  State<PortalSettingsTextField> createState() =>
      _PortalSettingsTextFieldState();
}

class _PortalSettingsTextFieldState extends State<PortalSettingsTextField> {
  late final TextEditingController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void didUpdateWidget(covariant PortalSettingsTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != null &&
        widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit(String value) async {
    if (widget.onSubmit == null || _isLoading) return;
    setState(() => _isLoading = true);
    try {
      await widget.onSubmit!(value);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null && widget.title!.isNotEmpty) ...[
            Text(
              widget.title!,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.8),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmit != null ? _handleSubmit : null,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                if (widget.onSubmit != null) ...[
                  const SizedBox(width: 8),
                  if (_isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: M3ECircularWavyProgressIndicator(
                        size: 20,
                        strokeWidth: 2,
                      ),
                    )
                  else
                    M3EButton(
                      onPressed: () => _handleSubmit(_controller.text),
                      style: M3EButtonStyle.tonal,
                      size: M3EButtonSize.sm,
                      decoration: M3EButtonDecoration.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Применить'),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

