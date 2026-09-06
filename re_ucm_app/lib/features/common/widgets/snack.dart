import 'package:material_ui/material_ui.dart';
import '../../../core/ui/tokens.dart';

void snackMessage(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      dismissDirection: DismissDirection.horizontal,
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.symmetric(
        vertical: AppSpacing.sm * 2 + MediaQuery.of(context).padding.bottom,
        horizontal: AppSpacing.sm * 2,
      ),
    ),
  );
}
