import 'package:flutter/material.dart';

class TagEditingController extends TextEditingController {
  TagEditingController({super.text});

  // Инвертированные скобки "панцирь черепахи" для максимальной уникальности
  // ⦘ (U+2998 Right Tortoise Shell Bracket)
  static const String startTagChar = '\u2998';
  // ⦗ (U+2997 Left Tortoise Shell Bracket)
  static const String endTagChar = '\u2997';

  // Регулярка: ищем всё между ⦘ и ⦗
  static final RegExp tagRegExp = RegExp(
    '$startTagChar([^$endTagChar]+)$endTagChar',
  );

  @override
  set value(TextEditingValue newValue) {
    // 1. ЛОГИКА УДАЛЕНИЯ (Atomicity)
    if (newValue.text.length < value.text.length) {
      // Ищем индекс, с которого началось изменение
      int changeIndex = -1;
      for (int i = 0; i < newValue.text.length; i++) {
        if (value.text[i] != newValue.text[i]) {
          changeIndex = i;
          break;
        }
      }
      if (changeIndex == -1) changeIndex = newValue.text.length;

      // Вычисляем границы удаленного фрагмента в старом тексте
      int deleteStart = changeIndex;
      int deleteEnd = changeIndex + (value.text.length - newValue.text.length);
      bool rangeExpanded = false;

      final matches = tagRegExp.allMatches(value.text);
      for (final match in matches) {
        // Проверяем, пересекается ли удаленный фрагмент с тегом
        if (deleteEnd > match.start && deleteStart < match.end) {
          // Если тег НЕ поглощен удалением полностью, а лишь "надкушен" – расширяем зону удаления
          if (deleteStart > match.start) {
            deleteStart = match.start;
            rangeExpanded = true;
          }
          if (deleteEnd < match.end) {
            deleteEnd = match.end;
            rangeExpanded = true;
          }
        }
      }

      // Если мы расширили зону удаления (зацепили кусок тега), применяем новые границы
      if (rangeExpanded) {
        final newText = value.text.replaceRange(deleteStart, deleteEnd, "");
        super.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: deleteStart),
        );
        return;
      }
    }

    // 2. ЛОГИКА НАВИГАЦИИ (Прыжки через тег)
    final newSelection = newValue.selection;
    final oldSelection = value.selection;

    if (newSelection.isCollapsed && oldSelection.isValid) {
      final matches = tagRegExp.allMatches(newValue.text);

      for (final match in matches) {
        if (newSelection.baseOffset > match.start &&
            newSelection.baseOffset < match.end) {
          int newOffset;

          if (newSelection.baseOffset < oldSelection.baseOffset) {
            newOffset = match.start;
          } else if (newSelection.baseOffset > oldSelection.baseOffset) {
            newOffset = match.end;
          } else {
            final distToStart = newSelection.baseOffset - match.start;
            final distToEnd = match.end - newSelection.baseOffset;
            newOffset = (distToStart < distToEnd) ? match.start : match.end;
          }

          super.value = newValue.copyWith(
            selection: TextSelection.collapsed(offset: newOffset),
          );
          return;
        }
      }
    }

    super.value = newValue;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    bool withComposing = false,
  }) {
    final defaultStyle = style ?? DefaultTextStyle.of(context).style;
    final children = <InlineSpan>[];

    int currentPos = 0;
    final Iterable<RegExpMatch> matches = tagRegExp.allMatches(text);

    for (final match in matches) {
      // 1. Текст ДО тега
      if (match.start > currentPos) {
        children.add(
          TextSpan(
            text: text.substring(currentPos, match.start),
            style: defaultStyle,
          ),
        );
      }

      final String tagLabel = match.group(1) ?? "";
      final String fullMatch = match.group(0) ?? "";

      // 2. Виджет тега (заменяет собой визуально первый символ '⦘')
      children.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: _buildTagChip(context, tagLabel, defaultStyle),
        ),
      );

      // 3. Скрытый хвост тега (начиная со второго символа)
      if (fullMatch.length > 1) {
        children.add(
          TextSpan(
            text: fullMatch.substring(1),
            style: defaultStyle.copyWith(
              fontSize: 0.000001,
              color: Colors.transparent,
              letterSpacing: 0,
            ),
          ),
        );
      }

      currentPos = match.end;
    }

    // Хвост текста после последнего тега
    if (currentPos < text.length) {
      children.add(
        TextSpan(text: text.substring(currentPos), style: defaultStyle),
      );
    }

    return TextSpan(style: defaultStyle, children: children);
  }

  Widget _buildTagChip(BuildContext context, String label, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.5),
      child: Text(
        label,
        style: style.copyWith(color: ColorScheme.of(context).surfaceTint),
      ),
    );
  }

  void insertTag(String tagLabel) {
    // 1. Формируем строку тега с новыми асимметричными краями
    final String formattedTag = '$startTagChar$tagLabel$endTagChar';

    // 2. Определяем позицию вставки
    final currentText = text;
    final currentSelection = selection;

    final int start = currentSelection.isValid
        ? currentSelection.start
        : currentText.length;
    final int end = currentSelection.isValid
        ? currentSelection.end
        : currentText.length;

    // 3. Формируем новый текст
    final newText = currentText.replaceRange(start, end, formattedTag);

    // 4. Вычисляем новую позицию курсора (сразу после тега)
    final int newSelectionIndex = start + formattedTag.length;

    // 5. Обновляем значение контроллера
    value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newSelectionIndex),
    );
  }
}
