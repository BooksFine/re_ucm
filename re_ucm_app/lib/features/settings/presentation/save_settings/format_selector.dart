import 'package:flutter/material.dart';

class FormatSelector extends StatelessWidget {
  const FormatSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .spaceEvenly,
      children: [
        FormatButton(title: 'fb2', onPressed: () {}),
        FormatButton(title: 'fb2.zip', onPressed: () {}),
        FormatButton(title: 'epub', onPressed: () {}),
      ],
    );
  }
}

class FormatButton extends StatelessWidget {
  const FormatButton({super.key, this.onPressed, required this.title});

  final VoidCallback? onPressed;
  final String title;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(onPressed: onPressed, child: Text(title));
  }
}
