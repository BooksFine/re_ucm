part of '../settings.dart';

class SettingsTextField extends StatelessWidget {
  const SettingsTextField({
    super.key,
    required this.hint,
    required this.onTap,
    this.isLoading = false,
    required this.controller,
  });

  final String hint;
  final VoidCallback onTap;
  final bool isLoading;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: appPadding / 2),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: appPadding * 2,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
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
                    onTap: onTap,
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
        const SizedBox(width: appPadding / 2),
      ],
    );
  }
}
