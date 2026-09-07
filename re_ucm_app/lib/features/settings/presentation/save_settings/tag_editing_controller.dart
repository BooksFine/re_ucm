import 'package:material_ui/material_ui.dart';
import 'package:re_ucm_lib/re_ucm_lib.dart';

class TagEditingController extends TextEditingController {
  TagEditingController({super.text});

  static const String startTagChar = TemplateFormatter.startTagChar;
  static const String endTagChar = TemplateFormatter.endTagChar;
  static final RegExp tagRegExp = TemplateFormatter.tagRegExp;

  @override
  set value(TextEditingValue newValue) {
    var candidateValue = newValue;

    // 1. ЛОГИКА УДАЛЕНИЯ (Atomicity)
    if (candidateValue.text.length < value.text.length) {
      // Ищем индекс, с которого началось изменение
      int changeIndex = -1;
      for (int i = 0; i < candidateValue.text.length; i++) {
        if (value.text[i] != candidateValue.text[i]) {
          changeIndex = i;
          break;
        }
      }
      if (changeIndex == -1) changeIndex = candidateValue.text.length;

      // Вычисляем границы удаленного фрагмента в старом тексте
      int deleteStart = changeIndex;
      int deleteEnd =
          changeIndex + (value.text.length - candidateValue.text.length);
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
        final clampedOffset = deleteStart.clamp(0, newText.length);
        candidateValue = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: clampedOffset),
        );
      }
    }

    // 2. ЛОГИКА НАВИГАЦИИ (Прыжки через тег / стабилизация курсора)
    final sel = candidateValue.selection;
    if (sel.isValid) {
      final matches = tagRegExp.allMatches(candidateValue.text);

      if (sel.isCollapsed) {
        final offset = sel.baseOffset;
        if (offset >= 0 && offset <= candidateValue.text.length) {
          for (final match in matches) {
            if (offset > match.start && offset < match.end) {
              int newOffset;
              if (value.selection.isValid &&
                  offset < value.selection.baseOffset) {
                newOffset = match.start;
              } else if (value.selection.isValid &&
                  offset > value.selection.baseOffset) {
                newOffset = match.end;
              } else {
                final distToStart = offset - match.start;
                final distToEnd = match.end - offset;
                newOffset = (distToStart < distToEnd) ? match.start : match.end;
              }
              newOffset = newOffset.clamp(0, candidateValue.text.length);
              candidateValue = candidateValue.copyWith(
                selection: TextSelection.collapsed(offset: newOffset),
              );
              break;
            }
          }
        }
      } else {
        // Выделение диапазона: если граница попадает внутрь тега, расширяем
        int start = sel.start;
        int end = sel.end;
        bool adjusted = false;

        for (final match in matches) {
          if (start > match.start && start < match.end) {
            start = match.start;
            adjusted = true;
          }
          if (end > match.start && end < match.end) {
            end = match.end;
            adjusted = true;
          }
        }

        if (adjusted) {
          final isReversed = sel.extentOffset < sel.baseOffset;
          candidateValue = candidateValue.copyWith(
            selection: TextSelection(
              baseOffset: isReversed ? end : start,
              extentOffset: isReversed ? start : end,
            ),
          );
        }
      }
    }

    super.value = candidateValue;
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
        style: style.copyWith(
          color: ColorScheme.of(context).primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void insertTag(String tagLabel) {
    // 1. Формируем строку тега с новыми асимметричными краями
    final String formattedTag = '$startTagChar$tagLabel$endTagChar';

    // 2. Определяем позицию вставки
    final currentText = text;
    final currentSelection = selection;

    final int rawStart = currentSelection.isValid
        ? currentSelection.start
        : currentText.length;
    final int rawEnd = currentSelection.isValid
        ? currentSelection.end
        : currentText.length;

    final int start = rawStart.clamp(0, currentText.length);
    final int end = rawEnd.clamp(0, currentText.length);

    final int minPos = start <= end ? start : end;
    final int maxPos = start <= end ? end : start;

    // 3. Формируем новый текст
    final newText = currentText.replaceRange(minPos, maxPos, formattedTag);

    // 4. Вычисляем новую позицию курсора (сразу после тега)
    final int newSelectionIndex =
        (minPos + formattedTag.length).clamp(0, newText.length);

    // 5. Обновляем значение контроллера
    value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newSelectionIndex),
    );
  }
}
