import 'package:flutter/material.dart';

class TagEditingController extends TextEditingController {
  TagEditingController({super.text});

  // Регулярка: ищем всё между % и %
  static final RegExp tagRegExp = RegExp(r'%([^%]+)%');

  @override
  set value(TextEditingValue newValue) {
    // 1. ЛОГИКА УДАЛЕНИЯ (Atomicity)
    // Если текст стал короче (Backspace / Delete / Cut)
    if (newValue.text.length < value.text.length) {
      // Ищем индекс первого изменения
      int changeIndex = -1;
      // Сравниваем символы старого и нового текста
      for (int i = 0; i < newValue.text.length; i++) {
        if (value.text[i] != newValue.text[i]) {
          changeIndex = i;
          break;
        }
      }
      // Если расхождений не нашли, значит отрезали хвост
      if (changeIndex == -1) changeIndex = newValue.text.length;

      // Проверяем, попал ли индекс удаления внутрь тега в СТАРОМ тексте
      final matches = tagRegExp.allMatches(value.text);
      for (final match in matches) {
        // Если удаление затронуло диапазон тега (включая границы %)
        if (changeIndex >= match.start && changeIndex < match.end) {
          // Удаляем весь тег целиком
          final newText = value.text.replaceRange(match.start, match.end, "");

          super.value = TextEditingValue(
            text: newText,
            // Ставим курсор ровно туда, где был начал тега
            selection: TextSelection.collapsed(offset: match.start),
          );
          return;
        }
      }
    }

    // 2. ЛОГИКА НАВИГАЦИИ (Прыжки через тег)
    final newSelection = newValue.selection;
    final oldSelection =
        value.selection; // Используем текущее состояние контроллера

    // Работаем только с курсором (не с выделением диапазона)
    if (newSelection.isCollapsed && oldSelection.isValid) {
      final matches = tagRegExp.allMatches(newValue.text);

      for (final match in matches) {
        // Если курсор оказался ВНУТРИ тега (между % и %)
        if (newSelection.baseOffset > match.start &&
            newSelection.baseOffset < match.end) {
          int newOffset;

          // Определяем направление движения
          if (newSelection.baseOffset < oldSelection.baseOffset) {
            // Движение ВЛЕВО (были правее, стали левее) -> Прыгаем в НАЧАЛО тега
            newOffset = match.start;
          } else if (newSelection.baseOffset > oldSelection.baseOffset) {
            // Движение ВПРАВО (были левее, стали правее) -> Прыгаем в КОНЕЦ тега
            newOffset = match.end;
          } else {
            // Если кликнули мышкой внутрь: прыгаем к ближайшему краю
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

      // 2. Виджет тега (заменяет собой визуально первый символ '%')
      children.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: _buildTagChip(context, tagLabel, defaultStyle),
        ),
      );

      // 3. Скрытый хвост тега (начиная со второго символа)
      // Это нужно, чтобы курсор позиционировался правильно.
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
    // 1. Формируем строку тега
    final String formattedTag = '%$tagLabel%';

    // 2. Определяем позицию вставки
    final currentText = text;
    final currentSelection = selection;

    // Если курсора нет (поле не в фокусе), вставляем в конец.
    // Если есть выделение, заменяем его.
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

    // 5. Обновляем значение контроллера.
    // Это автоматически добавит действие в историю Undo (Ctrl+Z).
    value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newSelectionIndex),
    );
  }
}
