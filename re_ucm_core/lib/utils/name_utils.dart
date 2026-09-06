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
