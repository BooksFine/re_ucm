import 'package:dart_book/dart_book.dart';
import 'package:html/parser.dart' as html;
import '../../data/models/fb_chapter_info.dart';

List<FBChapterInfo> parseTableOfContents(
  String htmlSource,
  Uri baseUri,
  String defaultTitle,
) {
  final document = html.parse(htmlSource);
  final parts = document.querySelectorAll('li.part');

  if (parts.isEmpty) {
    return [FBChapterInfo(title: defaultTitle, url: baseUri)];
  }

  final chapters = <FBChapterInfo>[];
  for (final part in parts) {
    final link = part.querySelector('a.part-link');
    final heading = part.querySelector('h3');
    final title = heading?.text.trim() ?? 'Глава';
    final href = link?.attributes['href'];
    if (href != null && href.isNotEmpty) {
      chapters.add(FBChapterInfo(title: title, url: baseUri.resolve(href)));
    }
  }

  if (chapters.isEmpty) {
    chapters.add(FBChapterInfo(title: defaultTitle, url: baseUri));
  }

  return chapters;
}

BookSection parseChapterSection(
  String chapterHtml,
  String chapterTitle, {
  BookResourceRegistrar? registrar,
}) {
  final document = html.parse(chapterHtml);
  final contentNode =
      document.querySelector('.part_text') ??
      document.querySelector('#part_text') ??
      document.querySelector('.js-part-text') ??
      document.querySelector('#content') ??
      document.body;

  if (contentNode == null) {
    return BookSection(title: [BookText(chapterTitle)], blocks: const []);
  }

  // Remove unwanted non-content elements (ads, scripts, styles) without deleting text containers
  contentNode
      .querySelectorAll(
        'script, style, noscript, svg, .ad-block, .adv, .banner, .js-adv',
      )
      .forEach((n) => n.remove());

  final blocks = HtmlParser(registrar: registrar).parse(contentNode.nodes);
  return BookSection(title: [BookText(chapterTitle)], blocks: blocks);
}
