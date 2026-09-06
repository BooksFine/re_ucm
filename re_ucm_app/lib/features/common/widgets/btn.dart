import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';

class ElevatedButton1 extends StatelessWidget {
  const ElevatedButton1({
    super.key,
    required this.child,
    required this.func,
    this.isLoading = false,
    this.height,
  });
  final Widget child;
  final double? height;
  final void Function()? func;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: height ?? 48,
      width: double.infinity,
      child: M3EButton(
        onPressed: isLoading ? null : func,
        style: M3EButtonStyle.filled,
        size: M3EButtonSize.md,
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
                  color: theme.colorScheme.onPrimary,
                ),
              )
            : DefaultTextStyle(
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onPrimary,
                ),
                child: child,
              ),
      ),
    );
  }
}
