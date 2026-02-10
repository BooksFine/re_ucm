import 'package:flutter/material.dart';
import 'package:re_ucm_core/ui/constants.dart';
import '../../application/settings_service.cg.dart';
import '../../domain/path_placeholders.dart';
import '../../domain/path_template.cg.dart';
import 'tag_editing_controller copy.dart';
import 'tag_editing_controller.dart';

class DownloadPathEditor extends StatefulWidget {
  const DownloadPathEditor({super.key, required this.service});

  final SettingsService service;

  @override
  State<DownloadPathEditor> createState() => _DownloadPathEditorState();
}

class _DownloadPathEditorState extends State<DownloadPathEditor> {
  late TagEditingController2 pathController;
  final FocusNode focus = FocusNode();

  late bool isPathEmpty;

  void onPathChanged(String value) {
    final newIsEmpty = value.isEmpty;

    if (isPathEmpty != newIsEmpty) {
      isPathEmpty = newIsEmpty;
      setState(() {});
    }

    // final newTemplate = newIsEmpty
    //     ? PathTemplate.initial()
    //     : PathTemplate(
    //         path: value,
    //         placeholders: {
    //           for (final tag in pathController.tags)
    //             tag.index: PathPlaceholders.values.firstWhere(
    //               (e) => e.label == tag.label,
    //             ),
    //         },
    //       );

    // widget.service.updateDownloadPathTemplate(newTemplate);
  }

  final authorsSeparatorController = TextEditingController();
  void onAuthorsSeparatorChanged(String value) =>
      widget.service.updateAuthorsPathSeparator(value);

  @override
  void initState() {
    super.initState();
    final savedtemplate = widget.service.downloadPathTemplate;
    pathController = TagEditingController2(
      // text: savedtemplate.path,
      // tags: [
      //   for (final tag in savedtemplate.placeholders.entries)
      //     Tag(label: tag.value.label, index: tag.key),
      // ],
    );
    isPathEmpty = pathController.text.isEmpty;
    authorsSeparatorController.text = widget.service.authorsPathSeparator;
  }

  @override
  void dispose() {
    authorsSeparatorController.dispose();
    pathController.dispose();
    focus.dispose();
    super.dispose();
  }

  void _insertTemplateTag(String tag) {
    // pathController.insertTag(tag);
    focus.requestFocus();
    final newOffset = pathController.selection.baseOffset;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pathController.selection = TextSelection.collapsed(offset: newOffset);
    });
    onPathChanged(pathController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 48,
          child: TextField(
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
                        isPathEmpty = true;
                        setState(() {});
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
