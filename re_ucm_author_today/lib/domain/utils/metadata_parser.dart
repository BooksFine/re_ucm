import 'package:dart_book/dart_book.dart';

import '../../data/models/at_work_metadata.cg.dart';
import 'genre_from_id.dart';

BookMetadata metadataParserAT(ATWorkMetadata data) {
  final contributors = <BookContributor>[
    BookContributor(
      role: BookContributorRole.author,
      name: personNameFromFio(data.authorFIO),
      homePage: Uri.tryParse('https://author.today/u/${data.authorUserName}'),
    ),
  ];

  if (data.coAuthorId != null && data.coAuthorFIO != null) {
    contributors.add(
      BookContributor(
        role: BookContributorRole.author,
        name: personNameFromFio(data.coAuthorFIO!),
        homePage: data.coAuthorUserName != null
            ? Uri.tryParse('https://author.today/u/${data.coAuthorUserName}')
            : null,
      ),
    );
  }

  if (data.secondCoAuthorId != null && data.secondCoAuthorFIO != null) {
    contributors.add(
      BookContributor(
        role: BookContributorRole.author,
        name: personNameFromFio(data.secondCoAuthorFIO!),
        homePage: data.secondCoAuthorUserName != null
            ? Uri.tryParse('https://author.today/u/${data.secondCoAuthorUserName}')
            : null,
      ),
    );
  }

  var rawAnnotation =
      data.annotation != null ? "<p>${data.annotation}</p>" : null;
  if (data.authorNotes != null) {
    rawAnnotation ??= "";
    rawAnnotation +=
        "<p><b>Примечание автора:</b></p>"
        "<p>${data.authorNotes}</p>";
  }

  BookContent? annotationContent;
  if (rawAnnotation != null && rawAnnotation.isNotEmpty) {
    final blocks = HtmlParser().parseFromString(rawAnnotation);
    annotationContent = BookContent(blocks: blocks);
  }

  BookSeries? series;
  if (data.seriesId != null && data.seriesTitle != null) {
    series = BookSeries(
      name: data.seriesTitle!,
      number: data.seriesWorkNumber,
      url: Uri.tryParse("https://author.today/work/series/${data.seriesId}"),
    );
  }

  final genres = <BookGenre>[];
  for (var id in [data.genreId, data.firstSubGenreId, data.secondSubGenreId]) {
    if (id != null) {
      genres.add(genreFromId(id));
    }
  }

  return BookMetadata(
    id: data.id.toString(),
    title: data.title,
    language: 'ru',
    isFinished: data.isFinished,
    textLength: data.textLength,
    contributors: contributors,
    genres: genres,
    keywords: List<String>.from(data.tags),
    annotation: annotationContent,
    series: series,
    cover: _processCoverUrl(data.coverUrl) != null
        ? BookCover(
            ref: BookResourceRef(_processCoverUrl(data.coverUrl)!),
            alt: data.title,
          )
        : null,
    source: Uri.tryParse('https://author.today/work/${data.id}'),
    updatedAt: data.lastUpdateTime,
  );
}

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

String? _processCoverUrl(String? rawUrl) {
  if (rawUrl == null || rawUrl.isEmpty) return null;
  final uri = Uri.tryParse(rawUrl);
  if (uri == null) return rawUrl;

  final queryParams = Map<String, String>.from(uri.queryParameters)
    ..remove('width')
    ..remove('height')
    ..remove('rmode');

  return uri
      .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null)
      .toString();
}

