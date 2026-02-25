import 'package:flutter/material.dart';

import '../../../../core/ui/constants.dart';

class SettingsTextField extends StatelessWidget {
  const SettingsTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.onSubmit,
    this.onChanged,
    this.isLoading = false,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onSubmit;
  final ValueChanged<String>? onChanged;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: appPadding),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: appPadding / 2),
            child: TextField(
              onChanged: onChanged,
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: appPadding,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        if (onSubmit != null)
          AnimatedSwitcher(
            duration: Durations.medium2,
            child: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(appPadding),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Material(
                    color: Colors.transparent,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => onSubmit!(controller.text),
                      child: Padding(
                        padding: const EdgeInsets.all(appPadding),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
          ),
        const SizedBox(width: appPadding),
      ],
    );
  }
}
