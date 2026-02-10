import 'package:flutter/material.dart';

class Tag {
  String label;
  int index;

  @override
  String toString() {
    return 'Tag(label: $label, index: $index)';
  }

  Tag({required this.label, required this.index});
}

class TagEditingController extends TextEditingController {
  final List<Tag> tags;
  static const String tagSymbol = '\uFFFC';

  TagEditingController({super.text, List<Tag>? tags}) : tags = tags ?? [];

  void _updateTagIndexes({
    required int changeStartIndex,
    required int removedLength,
    required int addedLength,
  }) {
    final newTags = <Tag>[];

    for (final tag in tags) {
      if (tag.index < changeStartIndex) {
        newTags.add(tag);
        continue;
      }

      if (tag.index < changeStartIndex + removedLength) continue;

      tag.index -= removedLength;
      tag.index += addedLength;

      newTags.add(tag);
    }

    tags.clear();
    tags.addAll(newTags);
  }

  void insertTag(String label) {
    final currentSelection = selection;
    final currentText = text;
    int selectionStart = currentSelection.start;
    int selectionEnd = currentSelection.end;

    if (selectionStart < 0) {
      selectionStart = 0;
      selectionEnd = 0;
    }

    final newText = currentText.replaceRange(
      selectionStart,
      selectionEnd,
      tagSymbol,
    );
    final newOffset = selectionStart + tagSymbol.length;

    final newTag = Tag(label: label, index: selectionStart);

    final newValue = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset),
    );

    _updateTagIndexes(
      changeStartIndex: selectionStart,
      addedLength: 1,
      removedLength: selectionEnd - selectionStart,
    );

    int insertAtIndex = tags.indexWhere((tag) => tag.index >= newTag.index);
    if (insertAtIndex == -1) {
      tags.add(newTag);
    } else {
      tags.insert(insertAtIndex, newTag);
    }

    super.value = newValue;
  }

  @override
  set value(TextEditingValue newValue) {
    _onChanged(newValue);
    super.value = newValue;
  }

  void _onChanged(TextEditingValue newValue) {
    final oldValue = value;
    final oldText = oldValue.text;
    final newText = newValue.text;

    if (newText == oldText) return;

    int commonPrefix = 0;
    while (commonPrefix < oldText.length &&
        commonPrefix < newText.length &&
        oldText[commonPrefix] == newText[commonPrefix]) {
      commonPrefix++;
    }

    int commonSuffix = 0;
    while (commonSuffix < oldText.length - commonPrefix &&
        commonSuffix < newText.length - commonPrefix &&
        oldText[oldText.length - 1 - commonSuffix] ==
            newText[newText.length - 1 - commonSuffix]) {
      commonSuffix++;
    }

    final int changeStartIndex = commonPrefix;
    final int removedLength =
        (oldText.length - commonSuffix) - changeStartIndex;
    final int addedLength = (newText.length - commonSuffix) - changeStartIndex;

    _updateTagIndexes(
      changeStartIndex: changeStartIndex,
      removedLength: removedLength,
      addedLength: addedLength,
    );
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

    for (final tag in tags) {
      if (tag.index < 0 || tag.index >= text.length) continue;

      if (text[tag.index] != tagSymbol) continue;

      // Add text before the tag
      if (tag.index > currentPos) {
        children.add(
          TextSpan(
            text: text.substring(currentPos, tag.index),
            style: defaultStyle,
          ),
        );
      }

      // Add the tag chip
      children.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: _buildTagChip(context, tag.label, defaultStyle),
        ),
      );
      // Move position past the tag symbol
      currentPos = tag.index + tagSymbol.length;
    }

    // Add any trailing text
    if (currentPos < text.length) {
      children.add(
        TextSpan(text: text.substring(currentPos), style: defaultStyle),
      );
    }

    // Handle empty text case
    if (children.isEmpty && text.isEmpty) {
      return TextSpan(text: '', style: defaultStyle);
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
