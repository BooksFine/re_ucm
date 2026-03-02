import 'package:flutter/material.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../../core/ui/constants.dart';
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

  late bool isPathEmpty;
  String? pathError;

  static final illegalChars = RegExp(r'[<>:"|?*]');

  @override
  void initState() {
    super.initState();
    pathController = TagEditingController(text: widget.initialPath);
    isPathEmpty = pathController.text.isEmpty;
  }

  @override
  void dispose() {
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

  void _insertTemplateTag(String tag) {
    pathController.insertTag(tag);
    onPathChanged(pathController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: appPadding * 1.6),
        TextField(
          groupId: 'test',
          scrollPadding: const EdgeInsets.all(0),
          controller: pathController,
          focusNode: focus,
          maxLines: 1,
          onChanged: onPathChanged,
          onTapOutside: (event) {
            focus.unfocus();
            if (pathController.text.isNotEmpty) return;
            onPathChanged(widget.initialPath);
            pathController.text = widget.initialPath;
          },
          style: TextStyle(
            color: ColorScheme.of(context).onSurfaceVariant,
            // height: 2,
          ),
          decoration: InputDecoration(
            errorText: pathError,
            visualDensity: VisualDensity.comfortable,
            floatingLabelStyle: TextStyle(
              // 16 / 0.75, компенсируем стандартное уменьшение Flutter'а
              fontSize: 21.65,
              color: ColorScheme.of(context).onSurfaceVariant,
            ),
            labelText: widget.title,
            labelStyle: TextStyle(
              fontSize: 16,
              color: ColorScheme.of(context).onSurfaceVariant,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: appPadding * 2,
            ),
            border: InputBorder.none,
            suffixIcon: Row(
              mainAxisSize: .min,
              children: [
                if (!isPathEmpty)
                  TapRegion(
                    groupId: 'test',
                    child: IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: ColorScheme.of(context).onSurfaceVariant,
                      ),
                      onPressed: () {
                        pathController.clear();
                        onPathChanged('');
                      },
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    Icons.save_as_outlined,
                    color: ColorScheme.of(context).onSurfaceVariant,
                  ),
                  onPressed: () {
                    if (pathError != null) return;
                    widget.onChanged(pathController.text);
                  },
                ),
                SizedBox(width: appPadding * 1.5),
              ],
            ),
          ),
        ),
        // const SizedBox(height: appPadding),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: appPadding * 1.5),
            itemCount: widget.placeholders.length,
            itemBuilder: (context, index) {
              final tag = widget.placeholders[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: PlaceholderButton(
                  title: tag.label,
                  groupId: 'test',
                  onTap: () => _insertTemplateTag(tag.label),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
