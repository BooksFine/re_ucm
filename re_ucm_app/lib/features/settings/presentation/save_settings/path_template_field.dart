import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../common/settings_input_decoration.dart';
import 'placeholder_button.dart';
import 'tag_editing_controller.dart';

class PathTemplateField extends StatefulWidget {
  const PathTemplateField({
    super.key,
    required this.initialPath,
    required this.onChanged,
    required this.title,
    this.placeholders = PathPlaceholders.values,
  });

  final String initialPath;
  final ValueChanged<String> onChanged;
  final String title;
  final List<PathPlaceholders> placeholders;

  @override
  State<PathTemplateField> createState() => _PathTemplateFieldState();
}

class _PathTemplateFieldState extends State<PathTemplateField> {
  late TagEditingController pathController;
  final FocusNode focus = FocusNode();

  late String path = widget.initialPath;
  late bool isPathEmpty;
  String? pathError;

  static final illegalChars = RegExp(r'[<>:"|?*]');

  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    pathController = TagEditingController(text: widget.initialPath);
    isPathEmpty = pathController.text.isEmpty;
    focus.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!focus.hasFocus && isEditing) {
      if (mounted) {
        setState(() => isEditing = false);
      }
    }
  }

  @override
  void didUpdateWidget(covariant PathTemplateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPath != oldWidget.initialPath && !isEditing) {
      pathController.text = widget.initialPath;
      path = widget.initialPath;
      isPathEmpty = widget.initialPath.isEmpty;
    }
  }

  @override
  void dispose() {
    focus.removeListener(_handleFocusChange);
    pathController.dispose();
    focus.dispose();
    super.dispose();
  }

  void onPathChanged(String value) {
    final newIsEmpty = value.isEmpty;
    final hasIllegal = illegalChars.hasMatch(value);

    final newError = hasIllegal ? 'Недопустимые символы: <>:"|?*' : null;

    if (isPathEmpty != newIsEmpty || pathError != newError) {
      isPathEmpty = newIsEmpty;
      pathError = newError;
      setState(() {});
    }
  }

  void onPathSaved() {
    if (pathError != null) return;
    if (isPathEmpty) pathController.text = path;
    widget.onChanged(pathController.text);
    path = pathController.text;
    isEditing = false;
    focus.unfocus();
    setState(() {});
  }

  void insertTemplateTag(String tag) {
    pathController.insertTag(tag);
    onPathChanged(pathController.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          readOnly: !isEditing,
          scrollPadding: EdgeInsets.zero,
          controller: pathController,
          focusNode: focus,
          maxLines: 1,
          onTap: () {
            if (!isEditing) {
              setState(() => isEditing = true);
              focus.requestFocus();
            }
          },
          onChanged: onPathChanged,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
          decoration: settingsInputDecoration(
            context,
            labelText: widget.title,
            errorText: pathError,
            isEditing: isEditing,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 11,
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isEditing) ...[
                    if (!isPathEmpty)
                      IconButton(
                        padding: .zero,
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        tooltip: 'Очистить',
                        onPressed: () {
                          pathController.clear();
                          onPathChanged('');
                        },
                      ),
                    IconButton(
                      icon: Icon(
                        Icons.check_circle_rounded,
                        size: 22,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      tooltip: 'Применить',
                      onPressed: onPathSaved,
                    ),
                  ] else
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      tooltip: 'Редактировать',
                      onPressed: () {
                        setState(() => isEditing = true);
                        focus.requestFocus();
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: Durations.short4,
          alignment: Alignment.topCenter,
          child: isEditing
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 6),
                        child: Text(
                          'Доступные переменные (нажмите для вставки):',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final tag in widget.placeholders)
                            PlaceholderButton(
                              title: tag.label,
                              onTap: () => insertTemplateTag(tag.label),
                            ),
                        ],
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
