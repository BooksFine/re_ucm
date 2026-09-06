import 'package:dart_book/dart_book.dart';

PersonName personNameFromFio(String fio) {
  final parts = fio
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();

  return switch (parts.length) {
    1 => PersonName(nickname: parts[0], display: fio.trim()),
    2 => PersonName(first: parts[0], last: parts[1], display: fio.trim()),
    3 => PersonName(
      last: parts[0],
      first: parts[1],
      middle: parts[2],
      display: fio.trim(),
    ),
    _ => PersonName(display: fio.trim()),
  };
}

/// Единая точка отображения авторов. Раньше строка
/// `contributors.map(toDisplayString).join(', ')` была скопирована
/// в `download_book_header`, `live_download_card` и `book_sharer`.
extension BookMetadataDisplay on BookMetadata {
  String get authorsDisplay =>
      contributors.map((e) => e.name.toDisplayString()).join(', ');
}

/// Группировка разрядов «1234567 → 1 234 567».
/// Заменяет приватный `_formatNumber` из `download_book_header`.
String formatGrouped(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  var count = 0;
  for (var i = s.length - 1; i >= 0; i--) {
    buf.write(s[i]);
    count++;
    if (count % 3 == 0 && i != 0) buf.write(' ');
  }
  return buf.toString().split('').reversed.join();
}

/// Рендер инлайнов книги в plain text. Раньше жил приватным методом
/// в `BookSharer` — это утилита текста, а не шаринга.
String bookInlinesToPlainText(List<BookInline> inlines) {
  final buffer = StringBuffer();
  for (final inline in inlines) {
    switch (inline) {
      case BookText t:
        buffer.write(t.text);
      case BookEmphasis e:
        buffer.write(bookInlinesToPlainText(e.children));
      case BookStrong s:
        buffer.write(bookInlinesToPlainText(s.children));
      case BookStrike st:
        buffer.write(bookInlinesToPlainText(st.children));
      case BookNamedStyle n:
        buffer.write(bookInlinesToPlainText(n.inlines));
      case BookLink l:
        buffer.write(bookInlinesToPlainText(l.children));
      case BookSuperscript sup:
        buffer.write(bookInlinesToPlainText(sup.children));
      case BookSubscript sub:
        buffer.write(bookInlinesToPlainText(sub.children));
      default:
        break;
    }
  }
  return buffer.toString();
}
