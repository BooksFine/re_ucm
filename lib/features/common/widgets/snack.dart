import 'package:flutter/material.dart';
import 'package:re_ucm_core/ui/constants.dart';

void snackMessage(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      dismissDirection: DismissDirection.horizontal,
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.symmetric(
        vertical: appPadding * 2 + MediaQuery.of(context).padding.bottom,
        horizontal: appPadding * 2,
      ),
    ),
  );
}
