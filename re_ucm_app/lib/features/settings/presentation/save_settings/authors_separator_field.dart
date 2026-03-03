import 'package:flutter/material.dart';

import '../../../../core/ui/constants.dart';
import '../../presentation/settings_controller.cg.dart';

class AuthorsSeparatorField extends StatefulWidget {
  const AuthorsSeparatorField({super.key, required this.controller});

  final SettingsController controller;

  @override
  State<AuthorsSeparatorField> createState() => _AuthorsSeparatorFieldState();
}

class _AuthorsSeparatorFieldState extends State<AuthorsSeparatorField> {
  final authorsSeparatorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    authorsSeparatorController.text = widget.controller.authorsPathSeparator;
  }

  @override
  void dispose() {
    authorsSeparatorController.dispose();
    super.dispose();
  }

  void onAuthorsSeparatorChanged(String value) {
    widget.controller.updateAuthorsPathSeparator(value);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            'Разделитель для авторов:',
            style: TextStyle(
              fontSize: 16,
              color: ColorScheme.of(context).onSurfaceVariant,
            ),
          ),
          const SizedBox(width: appPadding * 2),
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: authorsSeparatorController,
                onChanged: onAuthorsSeparatorChanged,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
