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

  factory AppButton.icon({
    Key? key,
    required VoidCallback? onPressed,
    M3EButtonStyle style = M3EButtonStyle.filled,
    M3EButtonSize size = M3EButtonSize.md,
    bool isLoading = false,
    required Widget icon,
    required Widget label,
  }) {
    return AppButton(
      key: key,
      onPressed: onPressed,
      style: style,
      size: size,
      isLoading: isLoading,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 8),
          label,
        ],
      ),
    );
  }

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
      child: Stack(
        alignment: Alignment.center,
        children: [
          Visibility(
            visible: !isLoading,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: child,
          ),
          if (isLoading)
            Positioned.fill(
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: M3ECircularWavyProgressIndicator(
                    size: 20,
                    strokeWidth: 2,
                    color: indicatorColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
