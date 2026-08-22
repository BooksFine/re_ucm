import 'package:dart_book/dart_book.dart';
import 'package:flutter/material.dart';
import 'package:simple_html_css/simple_html_css.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AnnotationViewer extends StatelessWidget {
  const AnnotationViewer({super.key, required this.annotation});

  final BookContent annotation;

  @override
  Widget build(BuildContext context) {
    final htmlText = _blocksToHtml(annotation.blocks);

    return HTML.toRichText(
      context,
      htmlText,
      linksCallback: (link) =>
          launchUrlString(link, mode: LaunchMode.externalApplication),
      overrideStyle: {
        'a': TextStyle(
          color: Theme.of(context).colorScheme.primary,
          decoration: TextDecoration.none,
        ),
      },
      defaultTextStyle: Theme.of(context).textTheme.bodyMedium,
    );
  }

  static String _blocksToHtml(List<BookBlock> blocks) {
    final sb = StringBuffer();
    for (final block in blocks) {
      if (block is BookParagraph) {
        sb.write('<p>${_inlinesToHtml(block.inlines)}</p>');
      } else if (block is BookHeading) {
        sb.write(
          '<h${block.level}>${_inlinesToHtml(block.text)}</h${block.level}>',
        );
      } else if (block is BookRawHtmlBlock) {
        sb.write(block.html);
      } else if (block is BookSection) {
        if (block.title.isNotEmpty) {
          sb.write('<h3>${_inlinesToHtml(block.title)}</h3>');
        }
        sb.write(_blocksToHtml(block.blocks));
      }
    }
    return sb.toString();
  }

  static String _inlinesToHtml(List<BookInline> inlines) {
    final sb = StringBuffer();
    for (final inline in inlines) {
      if (inline is BookText) {
        sb.write(inline.text);
      } else if (inline is BookLineBreak) {
        sb.write('<br>');
      } else if (inline is BookStrong) {
        sb.write('<b>${_inlinesToHtml(inline.children)}</b>');
      } else if (inline is BookEmphasis) {
        sb.write('<i>${_inlinesToHtml(inline.children)}</i>');
      } else if (inline is BookLink) {
        sb.write(
          '<a href="${inline.href}">${_inlinesToHtml(inline.children)}</a>',
        );
      } else if (inline is BookRawHtmlInline) {
        sb.write(inline.html);
      }
    }
    return sb.toString();
  }
}
