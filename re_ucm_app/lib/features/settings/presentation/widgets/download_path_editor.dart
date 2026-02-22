import 'package:flutter/material.dart';
import '../../../../core/ui/constants.dart';
import '../../domain/path_placeholders.dart';
import '../../domain/path_template.cg.dart';
import '../../presentation/settings_controller.cg.dart';
import 'tag_editing_controller.dart';

class DownloadPathEditor extends StatefulWidget {
  const DownloadPathEditor({super.key, required this.controller});

  final SettingsController controller;

  @override
  State<DownloadPathEditor> createState() => _DownloadPathEditorState();
}

class _DownloadPathEditorState extends State<DownloadPathEditor> {
  late TagEditingController pathController;
  final FocusNode focus = FocusNode();

  late bool isPathEmpty;

  void onPathChanged(String value) {
    final newIsEmpty = value.isEmpty;

    if (isPathEmpty != newIsEmpty) {
      isPathEmpty = newIsEmpty;
      setState(() {});
    }

    final newTemplate = PathTemplate(path: value);

    widget.controller.updateDownloadPathTemplate(newTemplate);
  }

  final authorsSeparatorController = TextEditingController();
  void onAuthorsSeparatorChanged(String value) =>
      widget.controller.updateAuthorsPathSeparator(value);

  @override
  void initState() {
    super.initState();
    final savedTemplate = widget.controller.downloadPathTemplate;
    pathController = TagEditingController(text: savedTemplate.path);
    isPathEmpty = pathController.text.isEmpty;
    authorsSeparatorController.text = widget.controller.authorsPathSeparator;
  }

  @override
  void dispose() {
    authorsSeparatorController.dispose();
    pathController.dispose();
    focus.dispose();
    super.dispose();
  }

  void _insertTemplateTag(String tag) {
    focus.requestFocus();
    pathController.insertTag(tag);
    onPathChanged(pathController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 48,
          child: TextField(
            selectAllOnFocus: false,
            scrollPadding: EdgeInsets.all(0),
            controller: pathController,
            focusNode: focus,
            maxLines: 1,
            onChanged: onPathChanged,
            style: TextStyle(
              color: ColorScheme.of(context).onSurfaceVariant,
              height: 2,
            ),
            decoration: InputDecoration(
              visualDensity: VisualDensity.comfortable,
              floatingLabelStyle: TextStyle(
                fontSize: 20,
                color: ColorScheme.of(context).onSurfaceVariant,
              ),
              labelText: 'Шаблон пути скачивания',
              labelStyle: TextStyle(
                color: ColorScheme.of(context).onSurfaceVariant,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: appPadding * 2),
              border: InputBorder.none,
              suffixIcon: isPathEmpty
                  ? null
                  : IconButton(
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
          ),
        ),
        const SizedBox(height: appPadding * 1.5),

        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: appPadding * 1.5),
            itemCount: PathPlaceholders.values.length,
            itemBuilder: (context, index) {
              final tag = PathPlaceholders.values[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: PlaceholderButton(
                  title: tag.label,
                  onTap: () => _insertTemplateTag(tag.label),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: appPadding * 1.5),

        SizedBox(height: appPadding * 1.5),
        Padding(
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
              SizedBox(width: appPadding * 2),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: authorsSeparatorController,
                    onChanged: onAuthorsSeparatorChanged,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PlaceholderButton extends StatelessWidget {
  const PlaceholderButton({
    super.key,
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: ColorScheme.of(context).onSurface,
      ),
      onPressed: onTap,
      child: Text(title),
    );
  }
}
