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
/// TODO: прокинуть [SettingsService.authorsPathSeparator] на call-сайтах
/// (downloads/recent — вне владения core) вместо дефолта ', '.
extension BookMetadataDisplay on BookMetadata {
  String get authorsDisplay => authorsText();

  String authorsText([String separator = ', ']) =>
      contributors.map((e) => e.name.toDisplayString()).join(separator);
}

/// Группировка разрядов «1234567 → 1 234 567».
/// Раньше приватный `_formatNumber` из `download_book_header`.
/// Без intl-зависимости: разделитель — обычный пробел (NumberFormat под
/// локалью ru отдал бы nbsp и потянул новую зависимость в core).
String formatGrouped(int n) {
  final isNegative = n < 0;
  final s = n.abs().toString();
  final buf = StringBuffer();
  var count = 0;
  for (var i = s.length - 1; i >= 0; i--) {
    buf.write(s[i]);
    count++;
    if (count % 3 == 0 && i != 0) buf.write(' ');
  }
  final grouped = buf.toString().split('').reversed.join();
  return isNegative ? '-$grouped' : grouped;
}

/// Рендер инлайнов книги в plain text. Раньше жил приватным методом
/// в `BookSharer` — это утилита текста, а не шаринга.
/// Ветки-контейнеры схлопнуты в один or-паттерн: все они рекурсивно
/// рендерят детей; остальное (картинки, разрывы, сноски) игнорируется.
String bookInlinesToPlainText(List<BookInline> inlines) {
  final buffer = StringBuffer();
  for (final inline in inlines) {
    switch (inline) {
      case BookText(text: final text):
        buffer.write(text);
      case BookEmphasis(children: final children) ||
          BookStrong(children: final children) ||
          BookStrike(children: final children) ||
          BookLink(children: final children) ||
          BookSuperscript(children: final children) ||
          BookSubscript(children: final children) ||
          BookNamedStyle(inlines: final children):
        buffer.write(bookInlinesToPlainText(children));
      case _:
        break;
    }
  }
  return buffer.toString();
}
