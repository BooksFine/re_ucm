import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    this.style = M3EButtonStyle.filled,
    this.size = M3EButtonSize.md,
    this.isLoading = false,
    required this.child,
  });

  final VoidCallback? onPressed;
  final M3EButtonStyle style;
  final M3EButtonSize size;
  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = style == M3EButtonStyle.filled
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.primary;

    return M3EButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      size: size,
      decoration: M3EButtonDecoration.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: M3ECircularWavyProgressIndicator(
                size: 20,
                strokeWidth: 2,
                color: indicatorColor,
              ),
            )
          : child,
    );
  }
}
