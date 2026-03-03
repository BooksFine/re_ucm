import 'package:flutter/material.dart';

class PlaceholderButton extends StatelessWidget {
  const PlaceholderButton({
    super.key,
    required this.title,
    required this.groupId,
    required this.onTap,
  });

  final String title;
  final String groupId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      groupId: groupId,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: ColorScheme.of(context).onSurface,
        ),
        onPressed: onTap,
        child: Text(title),
      ),
    );
  }
}
