import 'package:flutter/material.dart';

class TagEditingController2 extends TextEditingController {
  TagEditingController2();

  static final RegExp _tagRegExp = RegExp(r'%([^%]+)%');

  @override
  set value(TextEditingValue newValue) {

    print(newValue.selection);

    super.value = newValue;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    bool withComposing = false, // Consider handling composing regions if needed
  }) {
    final defaultStyle = style ?? DefaultTextStyle.of(context).style;
    final children = <InlineSpan>[];

    int currentPos = 0;

    final Iterable<RegExpMatch> matches = _tagRegExp.allMatches(text);

    for (final match in matches) {
      final tagStartIndex = match.start;
      final tagEndIndex = match.end;
      final String? tagLabel = match.group(1);

      if (tagLabel == null || tagLabel.isEmpty) continue;

      // Add text before the tag
      if (currentPos < tagStartIndex) {
        children.add(
          TextSpan(
            text: text.substring(currentPos, tagStartIndex),
            style: defaultStyle,
          ),
        );
      }

      // Add the tag as a chip
      children.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: _buildTagChip(context, tagLabel, defaultStyle),
        ),
      );

      currentPos = tagEndIndex;
    }

    if (currentPos < text.length) {
      children.add(
        TextSpan(text: text.substring(currentPos), style: defaultStyle),
      );
    }

    return TextSpan(style: defaultStyle, children: children);
  }

  // Helper to build the visual representation of the tag
  Widget _buildTagChip(BuildContext context, String label, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.5),
      child: Text(
        label,
        style: style.copyWith(color: ColorScheme.of(context).surfaceTint),
      ),
    );
  }
}
