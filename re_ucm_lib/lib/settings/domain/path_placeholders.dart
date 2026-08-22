import 'package:dart_book/dart_book.dart';
import 'package:re_ucm_core/models/portal.dart';

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

  String resolve(
    BookMetadata data,
    Portal portal,
    String authorsSeparator,
  ) {
    switch (this) {
      case PathPlaceholders.name:
        return data.title;
      case PathPlaceholders.series:
        return data.primarySeries?.name ?? '';
      case PathPlaceholders.seriesNumber:
        return data.primarySeries?.number?.toString() ?? '';
      case PathPlaceholders.authors:
        return data.contributors
            .map((e) => e.name.toDisplayString())
            .join(authorsSeparator);
      case PathPlaceholders.portal:
        return portal.name;
    }
  }
}
