import 'package:material_ui/material_ui.dart';
import '../../../core/ui/tokens.dart';

/// Круглая иконка-кнопка. Колбэк — только [onPressed].
class MyIconButton extends StatelessWidget {
  const MyIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.tooltip,
  });

  final Widget icon;

  /// Канонический колбэк.
  final VoidCallback? onPressed;
  final Color? backgroundColor;

  /// Подсказка при долгом нажатии. Без обёртки, если null/пусто.
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final callback = onPressed;
    Widget result = Material(
      shape: const CircleBorder(),
      color:
          backgroundColor ?? Theme.of(context).colorScheme.secondaryContainer,
      child: InkWell(
        onTap: callback,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: IconTheme(
            data: IconThemeData(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            child: icon,
          ),
        ),
      ),
    );
    final tip = tooltip;
    if (tip != null && tip.isNotEmpty) {
      result = Tooltip(message: tip, child: result);
    }
    return result;
  }
}
