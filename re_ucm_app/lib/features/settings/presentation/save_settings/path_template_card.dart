import 'package:flutter/material.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

import '../../../../core/ui/constants.dart';
import '../common/settings_animated_switcher.dart';
import 'path_template_field.dart';

class PathTemplateCard extends StatefulWidget {
  const PathTemplateCard({
    super.key,
    required this.title,
    required this.path,
    required this.onChanged,
    this.placeholders = PathPlaceholders.values,
  });

  final String title;
  final String path;
  final ValueChanged<String> onChanged;
  final List<PathPlaceholders> placeholders;

  @override
  State<PathTemplateCard> createState() => _PathTemplateCardState();
}

class _PathTemplateCardState extends State<PathTemplateCard> {
  List<InlineSpan> spans = [];
  bool isEditing = false;
  late String path = widget.path;

  @override
  void initState() {
    super.initState();
    updatePath(widget.path);
  }

  @override
  didUpdateWidget(covariant PathTemplateCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) updatePath(widget.path);
  }

  void updatePath(String path) {
    this.path = path;
    spans = getSpans(path);
    setState(() {});
  }

  List<InlineSpan> getSpans(String path) {
    final spans = <InlineSpan>[];
    final matches = TemplateFormatter.tagRegExp.allMatches(path);
    int lastMatchEnd = 0;

    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: path.substring(lastMatchEnd, match.start)));
      }

      final label = match.group(1);
      if (label != null) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: PathTemplateTagChip(label: label),
          ),
        );
      }
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < path.length) {
      spans.add(TextSpan(text: path.substring(lastMatchEnd)));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    // return Column(
    //   children: [
    //     Row(
    //       children: [
    //         SizedBox(width: appPadding * 2),
    //         Text(
    //           widget.title,
    //           style: TextStyle(
    //             fontSize: 16,
    //             color: ColorScheme.of(context).onSurfaceVariant,
    //           ),
    //         ),
    //         Spacer(),
    //         if (isEditing)
    //           IconButton(
    //             icon: Icon(
    //               Icons.save_as_outlined,
    //               color: ColorScheme.of(context).onSurfaceVariant,
    //             ),
    //             onPressed: () => setState(() => isEditing = false),
    //           ),
    //         SizedBox(width: appPadding * 2),
    //       ],
    //     ),
    //     SizedBox(height: appPadding),
    //     SettingsAnimatedSwitcher(
    //       child: isEditing
    //           ? PathTemplateField(
    //               initialPath: widget.path,
    //               onChanged: widget.onChanged,
    //             )
    //           : Row(
    //               children: [
    //                 SizedBox(width: appPadding * 2),
    //                 RichText(
    //                   text: TextSpan(
    //                     style: TextStyle(
    //                       color: ColorScheme.of(context).onSurfaceVariant,
    //                       fontSize: 14,
    //                       height: 1.5,
    //                     ),
    //                     children: spans,
    //                   ),
    //                 ),
    //                 Spacer(),
    //                 IconButton(
    //                   onPressed: () => setState(() => isEditing = true),
    //                   icon: Icon(
    //                     Icons.edit_outlined,
    //                     color: ColorScheme.of(context).onSurfaceVariant,
    //                   ),
    //                 ),
    //                 SizedBox(width: appPadding * 2),
    //               ],
    //             ),
    //     ),
    //   ],
    // );

    return SettingsAnimatedSwitcher(
      child: isEditing
          ? PathTemplateField(
              title: widget.title,
              initialPath: path,
              placeholders: widget.placeholders,
              onChanged: (v) {
                widget.onChanged(v);
                isEditing = false;
                updatePath(v);
              },
            )
          : ListTile(
              title: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 16,
                  color: ColorScheme.of(context).onSurfaceVariant,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: ColorScheme.of(context).onSurfaceVariant,
                    ),
                    children: spans,
                  ),
                ),
              ),
              contentPadding: .only(
                left: appPadding * 2,
                right: appPadding * 1.5,
              ),
              trailing: IconButton(
                onPressed: () => setState(() => isEditing = true),
                icon: Icon(
                  Icons.edit_outlined,
                  color: ColorScheme.of(context).onSurfaceVariant,
                ),
              ),
            ),
    );
  }
}

class PathTemplateTagChip extends StatelessWidget {
  const PathTemplateTagChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .symmetric(horizontal: 2),
      child: Chip(label: Text(label), labelPadding: EdgeInsets.zero),
    );
  }
}
