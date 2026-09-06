import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';

class OutlinedButton1 extends StatelessWidget {
  const OutlinedButton1({
    super.key,
    required this.text,
    required this.func,
    this.isLoading = false,
    this.height,
  });
  final String text;
  final double? height;
  final bool isLoading;
  final void Function()? func;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: height ?? 48,
      width: double.infinity,
      child: M3EButton(
        onPressed: isLoading ? null : func,
        style: M3EButtonStyle.outlined,
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
                  color: theme.colorScheme.primary,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: func != null
                      ? theme.colorScheme.primary
                      : theme.disabledColor,
                ),
              ),
      ),
    );
  }
}
