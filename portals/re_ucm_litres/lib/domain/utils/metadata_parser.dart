import 'package:dart_book/dart_book.dart';
import 'package:re_ucm_core/utils/name_utils.dart';

import '../../data/models/lr_art.cg.dart';
import '../constants.dart';
import 'genre_mapper.dart';

BookMetadata metadataParserLR(LRArt art) {
  final contributors = <BookContributor>[];

  for (final person in art.persons) {
    final role = _mapRole(person.role);
    final homePage = person.url != null && person.url!.isNotEmpty
        ? Uri.tryParse(
            person.url!.startsWith('http')
                ? person.url!
                : '$urlLitres${person.url}',
          )
        : null;

    contributors.add(
      BookContributor(
        role: role,
        name: personNameFromFio(person.fullName),
        homePage: homePage,
      ),
    );
  }

  if (contributors.isEmpty) {
    contributors.add(
      const BookContributor(
        role: BookContributorRole.author,
        name: PersonName(display: 'LitRes'),
      ),
    );
  }

  final rawAnnotation = art.htmlAnnotation ?? art.originalHtmlAnnotation;
  BookContent? annotationContent;
  if (rawAnnotation != null && rawAnnotation.trim().isNotEmpty) {
    final blocks = HtmlParser().parseFromString(rawAnnotation);
    annotationContent = BookContent(blocks: blocks);
  }

  final seriesList = <BookSeries>[];
  for (final s in art.series) {
    if (s.name != null && s.name!.isNotEmpty) {
      final number = int.tryParse(s.number?.toString() ?? '');
      final seriesUrl = s.url != null && s.url!.isNotEmpty
          ? (s.url!.startsWith('http') ? s.url! : '$urlLitres${s.url}')
          : (s.id != null ? '$urlLitres/serii-knig/?id=${s.id}' : null);

      seriesList.add(
        BookSeries(
          name: s.name!,
          number: number,
          url: seriesUrl != null ? Uri.tryParse(seriesUrl) : null,
        ),
      );
    }
  }

  final genres = <BookGenre>[];
  for (final g in art.genres) {
    if (g.name != null && g.name!.isNotEmpty) {
      genres.add(mapLitresGenre(id: g.id, name: g.name, url: g.url));
    }
  }

  final keywords = art.tags
      .map((t) => t.name)
      .whereType<String>()
      .where((t) => t.isNotEmpty)
      .toList();

  final coverUrl = _processCoverUrl(art.coverUrl);

  DateTime? updatedAt;
  if (art.lastUpdatedAt != null) {
    updatedAt = DateTime.tryParse(art.lastUpdatedAt!);
  }

  return BookMetadata(
    id: art.id.toString(),
    title: art.title,
    language: art.languageCode ?? 'ru',
    isFinished: art.isFinished ?? false,
    textLength: art.symbolsCount,
    contributors: contributors,
    genres: genres,
    keywords: keywords,
    annotation: annotationContent,
    series: seriesList,
    cover: coverUrl != null
        ? BookCover(ref: BookResourceRef(coverUrl), alt: art.title)
        : null,
    source: Uri.tryParse('$urlLitres/book/${art.id}'),
    updatedAt: updatedAt,
  );
}

BookContributorRole _mapRole(String? role) {
  return switch (role?.toLowerCase()) {
    'author' => BookContributorRole.author,
    'translator' => BookContributorRole.translator,
    'editor' => BookContributorRole.editor,
    'illustrator' || 'painter' => BookContributorRole.illustrator,
    'compiler' => BookContributorRole.compiler,
    'narrator' => BookContributorRole.narrator,
    _ => BookContributorRole.other,
  };
}

String? _processCoverUrl(String? rawUrl) {
  if (rawUrl == null || rawUrl.trim().isEmpty) return null;
  if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
    return rawUrl;
  }
  return '$urlLitres$rawUrl';
}
