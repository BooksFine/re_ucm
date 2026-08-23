import 'package:dart_book/dart_book.dart';
import 'package:html/parser.dart' as html;
import '../constants.dart';

BookMetadata metadataParserFB(String htmlSource, String id, Uri baseUri) {
  final document = html.parse(htmlSource);

  // Title
  final titleElement = document.querySelector('h1.fanfic-inline-title') ??
      document.querySelector('h1');
  final title = titleElement?.text.trim() ?? 'Без названия';

  // Authors
  final contributors = <BookContributor>[];
  final authorElements = document.querySelectorAll('a.creator-username');
  if (authorElements.isNotEmpty) {
    for (final el in authorElements) {
      final name = el.text.trim();
      if (name.isEmpty) continue;
      final href = el.attributes['href'];
      final homePage = href != null ? Uri.tryParse('$urlFB$href') : null;
      contributors.add(
        BookContributor(
          role: BookContributorRole.author,
          name: PersonName(display: name, nickname: name),
          homePage: homePage,
        ),
      );
    }
  } else {
    contributors.add(
      const BookContributor(
        role: BookContributorRole.author,
        name: PersonName(display: 'Ficbook Author'),
      ),
    );
  }

  // Cover
  BookCover? cover;
  final coverTag = document.querySelector('fanfic-cover') ??
      document.querySelector('.fanfic-cover img');
  final coverSrc = coverTag?.attributes['src-original'] ??
      coverTag?.attributes['src'];
  if (coverSrc != null && coverSrc.isNotEmpty) {
    final coverUri = baseUri.resolve(coverSrc).toString();
    cover = BookCover(
      ref: BookResourceRef(coverUri),
      alt: title,
    );
  }

  // Annotation
  BookContent? annotationContent;
  final descElement = document.querySelector('div[itemprop="description"]') ??
      document.querySelector('.fanfic-description-section');
  if (descElement != null && descElement.innerHtml.trim().isNotEmpty) {
    final blocks = HtmlParser().parseFromString(descElement.innerHtml);
    annotationContent = BookContent(blocks: blocks);
  }

  // Tags & Keywords & Fandoms
  final keywords = <String>[];
  final tagElements = document.querySelectorAll('a.tag, a.fandom-link, .badge-tag');
  for (final tagEl in tagElements) {
    final tagText = tagEl.text.trim();
    if (tagText.isNotEmpty && !keywords.contains(tagText)) {
      keywords.add(tagText);
    }
  }

  // Status (Finished / In progress)
  final bodyText = document.body?.text ?? '';
  final isFinished = bodyText.contains('Завершён') ||
      bodyText.contains('завершён') ||
      document.querySelector('.badge-status-finished') != null;

  return BookMetadata(
    id: id,
    title: title,
    language: 'ru',
    isFinished: isFinished,
    contributors: contributors,
    keywords: keywords,
    annotation: annotationContent,
    cover: cover,
    source: Uri.tryParse('$urlFB/readfic/$id'),
  );
}
