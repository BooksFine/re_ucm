import 'package:re_ucm_core/models/book.dart';
import 'package:re_ucm_core/models/portal.dart';

import '../../data/models/at_work_metadata.cg.dart';
import 'genre_from_id.dart';

Book metadataParserAT(ATWorkMetadata data, Portal portal) {
  List<Author> authors = [];

  authors.add(Author(
    url: 'https://author.today/u/${data.authorUserName}',
    name: data.authorFIO,
  ));
  if (data.coAuthorId != null) {
    authors.add(Author(
      url: 'https://author.today/u/${data.coAuthorUserName}',
      name: data.coAuthorFIO!,
    ));
  }
  if (data.secondCoAuthorId != null) {
    authors.add(Author(
      url: 'https://author.today/u/${data.secondCoAuthorUserName}',
      name: data.secondCoAuthorFIO!,
    ));
  }

  var annotation = data.annotation != null ? "<p>${data.annotation}</p>" : null;
  if (data.authorNotes != null) {
    annotation ??= "";
    annotation += "<b>Примечание автора:</b>"
        "<br>"
        "<p>${data.authorNotes}</p>";
  }

  Series? series;
  if (data.seriesId != null) {
    series = Series(
      url: "https://author.today/work/series/${data.seriesId}",
      name: data.seriesTitle!,
      number: data.seriesWorkNumber!,
    );
  }

  var genres = <Genre>[];
  for (var id in [data.genreId, data.firstSubGenreId, data.secondSubGenreId]) {
    if (id != null) {
      genres.add(genreFromId(id));
    }
  }

  Book book = Book(
    id: data.id.toString(),
    url: 'https://author.today/work/${data.id}',
    title: data.title,
    authors: authors,
    annotation: annotation,
    isFinished: data.isFinished,
    lastUpdateTime: data.lastUpdateTime,
    coverUrl: data.coverUrl,
    genres: genres,
    tags: List<String>.from(data.tags),
    series: series,
    textLength: data.textLength,
    portal: portal,
  );

  return book;
}
