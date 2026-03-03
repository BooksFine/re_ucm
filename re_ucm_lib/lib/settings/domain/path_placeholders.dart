import 'package:re_ucm_core/models/book.dart';

enum PathPlaceholders {
  name('Название'),
  series('Серия'),
  seriesNumber('Номер в серии'),
  authors('Авторы'),
  portal('Портал');

  final String label;

  const PathPlaceholders(this.label);

  static PathPlaceholders? fromLabel(String label) {
    for (final value in PathPlaceholders.values) {
      if (value.label == label) return value;
    }
    return null;
  }

  String resolve(Book data, String authorsSeparator) {
    switch (this) {
      case PathPlaceholders.name:
        return data.title;
      case PathPlaceholders.series:
        return data.series?.name ?? '';
      case PathPlaceholders.seriesNumber:
        return data.series?.number.toString() ?? '';
      case PathPlaceholders.authors:
        return data.authors.map((e) => e.name).join(authorsSeparator);
      case PathPlaceholders.portal:
        return data.portal.name;
    }
  }
}
